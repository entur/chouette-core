class AddResourceAttributesToImportMessages < ActiveRecord::Migration[4.2]
  def change
    add_column :import_messages, :resource_attributes, :hstore
  end
end
