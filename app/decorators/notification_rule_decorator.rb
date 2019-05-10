class NotificationRuleDecorator < AF83::Decorator
  decorates NotificationRule
  set_scope { context[:workbench] }

  create_action_link do |l|
    l.content t('notification_rules.actions.new')
  end

  with_instance_decorator do |instance_decorator|

    instance_decorator.show_action_link

    instance_decorator.edit_action_link

    instance_decorator.destroy_action_link
  end
end
