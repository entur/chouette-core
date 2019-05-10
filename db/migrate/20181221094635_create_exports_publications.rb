class CreateExportsPublications < ActiveRecord::Migration[4.2]
  def change
    add_column :exports, :publication_id, :integer, limit: 8
    add_index :exports, [:publication_id]
    remove_column :publications, :export_id, :integer
  end
end
