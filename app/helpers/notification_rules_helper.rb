module NotificationRulesHelper
  def notification_rules_metadatas(nr)
    {
      nr.object.class.tmf(:notification_type) => "notification_rules.notification_types.#{nr.notification_type}".t,
      nr.object.class.tmf(:period) =>  t('bounding_dates', debut: l(nr.period.min), end: l(nr.period.max)),
      nr.object.class.tmf(:line_id) => nr.line.name,
    }
  end
end
