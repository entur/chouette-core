class AddIndexToStopAreas < ActiveRecord::Migration[4.2]
  def change
    add_index :stop_areas, :name
  end
end
