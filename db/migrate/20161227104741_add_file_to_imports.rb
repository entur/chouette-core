class AddFileToImports < ActiveRecord::Migration[4.2]
  def change
    add_column :imports, :file, :string
  end
end
