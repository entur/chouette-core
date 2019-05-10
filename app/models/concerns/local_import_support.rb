module LocalImportSupport
  extend ActiveSupport::Concern

  included do |into|
    include ImportResourcesSupport
    after_commit :import_async, on: :create, unless: :profile?

    delegate :line_referential, :stop_area_referential, to: :workbench
    attr_accessor :profile
    attr_accessor :profile_options
    attr_accessor :profile_times
  end

  module ClassMethods
    def profile(filepath, profile_options={})
      import = self.new(file: open(filepath), creator: 'Profiler', workbench: Workbench.first)
      import.profile = true
      import.profile_options = profile_options
      import.name = "Profile #{File.basename(filepath)}"
      import.save!
      if profile_options[:operations]
        if profile_options[:reuse_referential]
          r = if profile_options[:reuse_referential].is_a?(Referential)
            profile_options[:reuse_referential]
          else
            Referential.where(name: import.referential_name).last
          end
          import.referential = r
          r.switch
        else
          import.create_referential
        end
      end
      import.save!
      if profile_options[:operations]
        import.profile_tag 'import' do
          ActiveRecord::Base.cache do
            import.import_resources *profile_options[:operations]
          end
        end
      else
        import.import
      end
      import
    end
  end

  def import_async
    Delayed::Job.enqueue LongRunningJob.new(self, :import), queue: :imports
  end

  def profile?
    @profile
  end

  def import
    update status: 'running', started_at: Time.now

    @progress = 0
    profile_tag 'import' do
      ActiveRecord::Base.cache do
        import_without_status
      end
    end
    @progress = nil
    @status ||= 'successful'
    referential&.active!
    update status: @status, ended_at: Time.now
  rescue => e
    update status: 'failed', ended_at: Time.now
    Rails.logger.error "Error in #{file_type} import: #{e} #{e.backtrace.join('\n')}"
    if (referential && overlapped_referential_ids = referential.overlapped_referential_ids).present?
      overlapped = Referential.find overlapped_referential_ids.last
      create_message(
        criticity: :error,
        message_key: "referential_creation_overlapping_existing_referential",
        message_attributes: {
          referential_name: referential.name,
          overlapped_name: overlapped.name,
          overlapped_url:  Rails.application.routes.url_helpers.referential_path(overlapped)
        }
      )
    else
      create_message criticity: :error, message_key: :full_text, message_attributes: {text: e.message}
    end
    referential&.failed!
  ensure
    main_resource&.save
    save
    notify_parent
    notify_state
  end

  def worker_died
    force_failure!

    Rails.logger.error "Import #{self.inspect} failed due to worker being dead"
  end

  def add_profile_time(tag, time)
    @profile_times ||= Hash.new{ |h, k| h[k] = [] }
    @profile_times[tag] << time
  end

  def profile_stats
    @profile_times ||= Hash.new{ |h, k| h[k] = [] }
    @computed_profile_stats ||= begin
      profile_stats = {}
      @profile_times.each do |k, times|
        sum = times.sum
        profile_stats[k] = {
          sum: sum,
          count: times.count,
          min: times.min,
          max: times.max,
          average: sum/times.count
        }
      end
      profile_stats
    end
  end

  def profile_tag(tag)
    @current_profile_scope ||= []
    @current_profile_scope << tag
    out = time = nil
    begin
      time = ::Benchmark.realtime do
        puts "START PROFILING #{@current_profile_scope.join('.')}"  if profile?
        out = yield
      end
      add_profile_time @current_profile_scope.join('.'), time if profile?
    ensure
      puts "END PROFILING #{@current_profile_scope.join('.')} in #{time}s" if profile?
      @current_profile_scope.pop
    end
    out
  end

  def profile_operation(operation, &block)
    if profile?
      profile_tag operation, &block
    else
      Chouette::Benchmark.log "#{self.class.name} import #{operation}" do
        yield
      end
    end
  end

  def import_resources(*resources)
    resources.each do |resource|
      profile_operation resource do
        send "import_#{resource}"

        notify_operation_progress(resource)
      end
    end
  end

  def create_referential
    profile_operation 'create_referential' do
      self.referential ||=  Referential.new(
        name: referential_name,
        organisation_id: workbench.organisation_id,
        workbench_id: workbench.id,
        metadatas: [referential_metadata]
      )

      if profile?
        Referential.find(self.referential.overlapped_referential_ids).each &:archive!
      end
      begin
        self.referential.save!
      rescue => e
        Rails.logger.error "Unable to create referential: #{self.referential.errors.messages}"
        raise
      end
      main_resource.update referential: referential if main_resource
    end
  end

  def referential_name
    name.presence || File.basename(local_file.to_s)
  end

  def notify_parent
    return unless super

    main_resource.update_status_from_importer self.status
    next_step
  end

  attr_accessor :local_file
  def local_file
    @local_file ||= download_local_file
  end

  attr_accessor :download_host
  def download_host
    @download_host ||= Rails.application.config.rails_host
  end

  def local_temp_directory
    @local_temp_directory ||=
      begin
        directory = Rails.application.config.try(:import_temporary_directory) || Rails.root.join('tmp', 'imports')
        FileUtils.mkdir_p directory
        directory
      end
  end

  def local_temp_file(&block)
    file = Tempfile.open("chouette-import", local_temp_directory)
    file.binmode
    yield file
  end

  def download_path
    Rails.application.routes.url_helpers.download_workbench_import_path(workbench, id, token: token_download)
  end

  def download_uri
    @download_uri ||=
      begin
        host = download_host
        host = "http://#{host}" unless host =~ %r{https?://}
        URI.join(host, download_path)
      end
  end

  def download_local_file
    local_temp_file do |file|
      begin
        Net::HTTP.start(download_uri.host, download_uri.port) do |http|
          http.request_get(download_uri.request_uri) do |response|
            response.read_body do |segment|
              file.write segment
            end
          end
        end
      end

      file.rewind
      file
    end
  end

  def save_model(model, filename: nil, line_number:  nil, column_number: nil, resource: nil)
    profile_tag "save_model.#{model.class.name}" do
      return unless model.changed?

      if resource
        filename ||= "#{resource.name}.txt"
        line_number ||= resource.rows_count
        column_number ||= 0
      end

      unless model.save
        Rails.logger.error "Can't save #{model.class.name} : #{model.errors.inspect}"

        # if the model cannot be saved, we still ensure we store a consistent checksum
        model.try(:update_checksum_without_callbacks!) if model.persisted?

        model.errors.details.each do |key, messages|
          messages.uniq.each do |message|
            message.each do |criticity, error|
              if Import::Message.criticity.values.include?(criticity.to_s)
                create_message(
                  {
                    criticity: criticity,
                    message_key: error,
                    message_attributes: {
                      test_id: key,
                      object_attribute: key,
                      source_attribute: key,
                    },
                    resource_attributes: {
                      filename: filename,
                      line_number: line_number,
                      column_number: column_number
                    }
                  },
                  resource: resource,
                  commit: true
                )
              end
            end
          end
        end
        @models_in_error ||= Hash.new { |hash, key| hash[key] = [] }
        @models_in_error[model.class.name] << model_key(model)
        @status = "failed"
        return
      end

      Rails.logger.debug "Created #{model.inspect}"
    end
  end

  def check_parent_is_valid_or_create_message(klass, key, resource)
    if @models_in_error&.key?(klass.name) && @models_in_error[klass.name].include?(key)
      create_message(
        {
          criticity: :error,
          message_key: :invalid_parent,
          message_attributes: {
            parent_class: klass,
            parent_key: key,
            test_id: :parent,
          },
          resource_attributes: {
            filename: "#{resource.name}.txt",
            line_number: resource.rows_count,
            column_number: 0
          }
        },
        resource: resource, commit: true
      )
      return false
    end
    true
  end

  def unless_parent_model_in_error(klass, key, resource)
    return unless check_parent_is_valid_or_create_message(klass, key, resource)

    yield
  end

  def model_key(model)
    return model.registration_number if model.respond_to?(:registration_number)

    return model.comment if model.is_a?(Chouette::TimeTable)
    return model.checksum_source if model.is_a?(Chouette::VehicleJourneyAtStop)

    model.objectid
  end
end
