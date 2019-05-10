module IevInterfaces::Resource
  extend ActiveSupport::Concern

  included do
    extend Enumerize
    attr_accessor :rows_count, :total_rows

    enumerize :status, in: %i[OK ERROR WARNING IGNORED], scope: true
    validates_presence_of :name, :resource_type
    before_save :update_metrics
    after_initialize do
      self.rows_count ||= 0
    end
  end

  def each(collection, opts = {})
    total_rows = collection.count
    checksum_manager_method = opts[:skip_checksums] ? :no_updates : :transaction

    inner_block = proc do |items|
      items.each do |item|
        inc_rows_count
        if self.respond_to?(:import)
          import.notify_sub_operation_progress(name, rows_count.to_f/total_rows)
        end
        yield item, self
      end
    end

    transaction_block = proc do |items|
      if opts[:transaction]
        ActiveRecord::Base.transaction do
          Chouette::ChecksumManager.send(checksum_manager_method) do
            inner_block.call items
          end
        end
      else
        inner_block.call items
      end
    end

    memory_block = proc do |items|
      if opts[:memory_profile]
        label = opts[:memory_profile]
        label = instance_exec(&label) if label.is_a?(Proc)
        Chouette::Benchmark.log label do
          transaction_block.call items
        end
      else
        transaction_block.call items
      end
    end

    if opts[:slice]
      collection.each_slice(opts[:slice]) do |slice|
        memory_block.call slice
      end
    else
      method = :each
      method = :find_each if collection.respond_to? :find_each
      collection.send(method) do |item|
        memory_block.call [item]
      end
    end

    update_status_from_messages
    save!
    self
  rescue
    failed!
    raise
  end

  def inc_rows_count
    @rows_count += 1
  end

  def update_status_from_importer(importer_status)
    update status: status_from_importer(importer_status)
  end

  def failed!
    update status: :ERROR
  end

  def update_status_from_messages
    update status: status_from_messages
  end

  def status_from_messages
    if messages.where(criticity: :error).exists?
      :ERROR
    elsif messages.where(criticity: :warning).exists?
      :WARNING
    else
      :OK
    end
  end

  def update_metrics
    warning = messages.warning.count
    error = messages.error.count
    self.metrics = {
      ok_count: [self.rows_count - warning - error].max,
      warning_count: warning,
      error_count: error
    }
  end

  def status_from_importer(importer_status)
    return nil unless importer_status.present?

    {
      new: nil,
      pending: nil,
      successful: :OK,
      warning: :WARNING,
      failed: :ERROR,
      running: nil,
      aborted: :ERROR,
      canceled: :ERROR
    }[importer_status.to_sym]
  end
end
