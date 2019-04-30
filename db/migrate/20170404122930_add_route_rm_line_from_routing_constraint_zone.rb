class AddRouteRmLineFromRoutingConstraintZone < ActiveRecord::Migration[4.2]
  def change
    remove_column :routing_constraint_zones, :line_id, :bigint
    add_column :routing_constraint_zones, :route_id, :bigint
  end
end
