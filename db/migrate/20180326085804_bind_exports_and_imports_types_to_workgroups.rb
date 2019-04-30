class BindExportsAndImportsTypesToWorkgroups < ActiveRecord::Migration[4.2]
  def change
    add_column :workgroups, "import_types", :string, default: [], array: true
    add_column :workgroups, "export_types", :string, default: [], array: true
  end
end
