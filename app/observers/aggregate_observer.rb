class AggregateObserver < NotifiableOperationObserver
  observe Aggregate, NightlyAggregate

  def mailer_name(model)
    'AggregateMailer'.freeze
  end
end
