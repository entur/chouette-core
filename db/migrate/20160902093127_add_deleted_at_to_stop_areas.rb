class AddDeletedAtToStopAreas < ActiveRecord::Migration[4.2]
  def change
    add_column :stop_areas, :deleted_at, :datetime
  end
end
