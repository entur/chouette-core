class AddMissingIndexes < ActiveRecord::Migration[4.2]
  def change
    add_index :journey_patterns, :route_id
    add_index :stop_points, :route_id
  end
end
