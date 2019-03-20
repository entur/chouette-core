class AddIgnoredStopAreaRoutingConstraintsToVehicleJourneys < ActiveRecord::Migration
  def change
    add_column :vehicle_journeys, :ignored_stop_area_routing_constraint_ids, :integer, array: true, default: []
  end
end
