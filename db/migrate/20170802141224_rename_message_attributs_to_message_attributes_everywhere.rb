class RenameMessageAttributsToMessageAttributesEverywhere < ActiveRecord::Migration[4.2]
  def change
    rename_column :import_messages, :message_attributs, :message_attributes
    rename_column :line_referential_sync_messages, :message_attributs, :message_attributes
    rename_column :stop_area_referential_sync_messages, :message_attributs, :message_attributes
  end
end
