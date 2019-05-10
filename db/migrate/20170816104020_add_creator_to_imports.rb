class AddCreatorToImports < ActiveRecord::Migration[4.2]
  def change
    add_column :imports, :creator, :string
  end
end
