class AddTypeToImports < ActiveRecord::Migration[4.2]
  def up
    add_column :imports, :type, :string
    execute "update imports set type = 'NetexImport' where type is null"
  end

  def down
    remove_column :imports, :type, :string
  end
end
