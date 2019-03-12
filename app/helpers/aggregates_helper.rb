module AggregatesHelper
  def aggregate_metadatas(aggregate)
    {
      Aggregate.tmf(:referentials) => aggregate.referentials.map{ |r| link_to(r.name, referential_path(r)) }.join(', ').html_safe,
      Aggregate.tmf(:status) => operation_status(aggregate.status, verbose: true, i18n_prefix: "aggregates.statuses"),
      Aggregate.tmf(:new) => aggregate.new ? link_to(aggregate.new.name, referential_path(aggregate.new)) : '-',
      Aggregate.tmf(:operator) => aggregate.creator,
      Aggregate.tmf(:created_at) => aggregate.created_at ? l(aggregate.created_at) : '-',
      Aggregate.tmf(:ended_at) => aggregate.ended_at ? l(aggregate.ended_at) : '-',
      Aggregate.tmf(:notification_target) => I18n.t("operation_support.notification_targets.#{aggregate.notification_target || 'none'}"),
      Aggregate.tmf(:contains_urgent_offer) => boolean_icon(aggregate.contains_urgent_offer?)
    }
  end

  def aggregate_status(aggregate)
    content_tag :span, '' do
      concat operation_status(aggregate.status)
      concat render_urgent_icon if aggregate.contains_urgent_offer?
    end
  end
end
