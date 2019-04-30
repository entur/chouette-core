class AddMetadataToRoutes < ActiveRecord::Migration[4.2]
  def change
    add_column :routes, :metadata, :jsonb
  end
end
