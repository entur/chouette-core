class AddPublicationApiIdToDestinations < ActiveRecord::Migration[4.2]
  def change
    add_column :destinations, :publication_api_id, :integer, limit: 8
    add_index :destinations, :publication_api_id
  end
end
