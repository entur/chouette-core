class RenameTypeInImportResource < ActiveRecord::Migration[4.2]
  def change
    rename_column :import_resources, :type, :resource_type
  end
end
