class Publication < ActiveRecord::Base
  extend Enumerize

  enumerize :status, in: %w[new pending successful failed running successful_with_warnings], default: :new

  belongs_to :publication_setup
  has_many :exports, class_name: 'Export::Base', dependent: :destroy
  belongs_to :parent, polymorphic: true
  has_many :reports, class_name: 'DestinationReport', dependent: :destroy

  validates :publication_setup, :parent, presence: true

  after_commit :publish, on: :create

  status.values.each do |s|
    define_method "#{s}!" do
      update status: s
    end

    define_method "#{s}?" do
      status.to_s == s
    end
  end

  def running!
    update_columns status: :running, started_at: Time.now
  end

  %i[failed successful successful_with_warnings].each do |s|
    define_method "#{s}!" do
      update status: s, ended_at: Time.now
    end
  end

  def publish
    return unless new?

    pending!
    if parent.successful?
      PublicationWorker.perform_async_or_fail(self)
    else
      failed!
    end
  end

  def pretty_date
    I18n.l(created_at)
  end

  def name
    self.class.tmf('name', setup_name: publication_setup.name, date: pretty_date)
  end

  def run
    running!
    run_export
  rescue
    failed!
  end

  def run_export
    all_synchronous = true
    publication_setup.new_exports(parent.new).each do |export|
      all_synchronous = all_synchronous && export.synchronous
      begin
        export.publication = self
        Rails.logger.info "Launching export #{export.name}"
        export.save!
      rescue => e
        Rails.logger.error "Error during Publication export: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        failed!
        return
      end

      if export.synchronous && !export.successful?
        Rails.logger.error "Publication Export '#{export.name}' failed"
        failed!
        return
      end
    end

    return unless all_synchronous

    send_to_destinations
    infer_status
  end

  def send_to_destinations
    publication_setup.destinations.each { |destination| destination.transmit(self) }
  end

  def child_change
    Rails.logger.info "child_change for #{inspect}"

    if exports.all?(&:finished?) && running?
      send_to_destinations
      infer_status
    end
  end

  def infer_status
    failed! && return unless exports.all?(&:successful?)

    new_status = reports.all?(&:successful?) ? :successful : :successful_with_warnings
    send("#{new_status}!")
  end

  def export_output
    export&.file
  end
end
