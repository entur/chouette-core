class Export::Message < ApplicationModel
  self.table_name = :export_messages

  include IevInterfaces::Message

  belongs_to :export, class_name: 'Export::Base'
  belongs_to :resource, class_name: 'Export::Resource'
end
