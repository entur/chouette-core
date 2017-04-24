class RmStopAreasAddStopPointsToRoutingConstraintZone < ActiveRecord::Migration
  def change
    remove_column :routing_constraint_zones, :stop_area_ids, :integer, array: true
    add_column :routing_constraint_zones, :stop_point_ids, :bigint, array: true
  end
end
