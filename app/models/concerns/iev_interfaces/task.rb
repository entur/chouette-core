module IevInterfaces::Task
  extend ActiveSupport::Concern
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::TagHelper
  include IconHelper
  include OperationsHelper

  included do
    belongs_to :parent, polymorphic: true
    belongs_to :workbench, class_name: "::Workbench"
    has_one :organisation, through: :workbench
    belongs_to :referential

    delegate :workgroup, to: :workbench

    mount_uploader :file, ImportUploader
    validates_integrity_of :file

    has_many :children, foreign_key: :parent_id, class_name: self.name, dependent: :destroy

    extend Enumerize
    enumerize :status, in: %w(new pending successful warning failed running aborted canceled), scope: true, default: :new

    validates :name, presence: true
    validates_presence_of :creator

    has_many :messages, class_name: messages_class_name, dependent: :destroy, foreign_key: "#{messages_class_name.split('::').first.downcase}_id"
    has_many :resources, class_name: resources_class_name, dependent: :destroy, foreign_key: "#{resources_class_name.split('::').first.downcase}_id"

    scope :where_started_at_in, ->(period_range) do
      where('started_at BETWEEN :begin AND :end', begin: period_range.begin, end: period_range.end)
    end

    scope :for_referential, ->(referential) do
      where(referential_id: referential.id)
    end

    scope :blocked, -> { where('created_at < ? AND status = ?', 4.hours.ago, 'running') }
    scope :successful, -> { where(status: :successful) }
    scope :new_or_pending, -> { where(status: [:new, :pending]) }

    before_save :initialize_fields, on: :create
    after_save :notify_parent
    # after_commit :notify_state, if: :status_changed?

    status.values.each do |s|
      define_method "#{s}!" do
        update_column :status, s
        notify_state
      end

      define_method "#{s}?" do
        status&.to_s == s
      end
    end
  end

  module ClassMethods
    def launched_statuses
      %w(new pending)
    end

    def failed_statuses
      %w(failed aborted canceled)
    end

    def finished_statuses
      %w(successful failed warning aborted canceled)
    end

    def abort_old
      where(
        'created_at < ? AND status NOT IN (?)',
        4.hours.ago,
        finished_statuses
      ).update_all(status: 'aborted')
    end
  end

  def workbench_for_notifications
    workbench || referential.workbench || referential.workgroup&.owner_workbench
  end

  def notify_parent
    return false unless finished?

    return false unless parent.present?
    return false if notified_parent_at
    parent.child_change

    update_column :notified_parent_at, Time.now
    true
  end

  def children_succeedeed
    children.with_status(:successful, :warning).count
  end

  def url_for_notifications(use_self=false)
    object = self
    object = parent if self.try(:parent) && !use_self
    [workbench_for_notifications, object]
  end

  def urls_to_refresh
    ([self] + children).map{ |i| polymorphic_url(i.url_for_notifications(true), only_path: true) }
  end

  def notify_state
    payload = self.slice(:id, :status, :name, :parent_id)
    payload.update({
      status_html: operation_status(self.status).html_safe,
      message_key: "#{self.class.name.underscore.gsub('/', '.')}.#{self.status}",
      url: polymorphic_url(url_for_notifications, only_path: true),
      urls_to_refresh: urls_to_refresh,
      unique_identifier: "#{self.class.name.underscore.gsub('/', '.')}-#{self.id}"
    })
    if self.class < Import::Base
      payload[:fragment] = "import-fragment"
    end
    if self.class < Export::Base
      payload[:fragment] = "export-fragment"
    end
    Notification.create! channel: workbench_for_notifications.notifications_channel, payload: payload
  end

  def notify_child_progress child, progress
    index = self.children.index child
    notify_progress (index+progress)/self.children.count
  end

  def notify_progress progress
    @previous_progress ||= 0
    return unless progress - @previous_progress >= 0.01
    @previous_progress = progress
    if parent
      parent.notify_child_progress self, progress
    else
      payload = self.slice(:id, :status, :name, :parent_id)
      payload.update({
        message_key: "#{self.class.name.underscore.gsub('/', '.')}.progress",
        status_html: operation_status(self.status).html_safe,
        url: polymorphic_url(url_for_notifications, only_path: true),
        urls_to_refresh: urls_to_refresh,
        unique_identifier: "#{self.class.name.underscore.gsub('/', '.')}-#{self.id}",
        progress: (progress*100).to_i
      })
      if self.class < Import::Base
        payload[:fragment] = "import-fragment"
      end
      Notification.create! channel: workbench_for_notifications.notifications_channel, payload: payload
    end
  end

  def operation_progress_weight(operation_name)
    1
  end

  def operations_progress_total_weight
    steps_count
  end

  def operation_relative_progress_weight(operation_name)
    operation_progress_weight(operation_name).to_f/operations_progress_total_weight
  end

  def notify_operation_progress(operation_name)
    if @progress
      @progress += operation_relative_progress_weight(operation_name)
      notify_progress @progress
    end
  end

  def notify_sub_operation_progress(operation_name, progress)
    notify_progress(@progress + operation_relative_progress_weight(operation_name)*progress) if @progress
  end

  def update_status
    Rails.logger.info "update_status for #{inspect}"
    status =
      if children.where(status: self.class.failed_statuses).count > 0
        'failed'
      elsif children.where(status: "warning").count > 0
        'warning'
      elsif children.where(status: "successful").count == children.count
        'successful'
      else
        'running'
      end

    attributes = {
      current_step: children.count,
      status: status
    }

    if self.class.finished_statuses.include?(status)
      attributes[:ended_at] = Time.now
    end

    update attributes
    notify_state
  end

  def finished?
    self.class.finished_statuses.include?(status)
  end

  def successful?
    status.to_s == "successful"
  end

  def warning?
    status.to_s == "warning"
  end

  def child_change
    return if self.class.finished_statuses.include?(status)
    update_status
  end

  def call_iev_callback
    return if self.class.finished_statuses.include?(status)
    threaded_call_boiv_iev
  end

  private

  def threaded_call_boiv_iev
    Thread.new(&method(:call_boiv_iev))
  end

  def call_boiv_iev
    Rails.logger.error("Begin IEV call for import")

    # Java code expects tasks in NEW status
    # Don't change status before calling iev

    Net::HTTP.get iev_callback_url
    Rails.logger.error("End IEV call for import")
  rescue Exception => e
    aborted!
    logger.error "IEV server error : #{e.message}"
    logger.error e.backtrace.inspect
  end

  private
  def initialize_fields
  end
end
