class AggregateDecorator < AF83::Decorator
  decorates Aggregate
  set_scope { context[:workgroup] }

  with_instance_decorator do |instance_decorator|
    instance_decorator.show_action_link do |l|
      l.content t('aggregates.actions.show')
      l.href do
        h.workgroup_aggregate_path(object.workgroup, object)
      end
    end

    instance_decorator.action_link(
      primary: :show,
      policy: :rollback
    ) do |l|
      l.content t('aggregates.actions.rollback')
      l.method  :put
      l.href do
        h.rollback_workgroup_aggregate_path(object.workgroup, object)
      end
      l.data {{ confirm: h.t('aggregates.actions.rollback_confirm') }}
    end
  end
end
