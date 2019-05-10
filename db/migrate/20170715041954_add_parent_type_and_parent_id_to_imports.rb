class AddParentTypeAndParentIdToImports < ActiveRecord::Migration[4.2]
  def change
    add_column :imports, :parent_id, :bigint
    add_column :imports, :parent_type, :string
  end
end
