class AddIgnoredStopAreaRoutingConstraintsToVehicleJourneys < ActiveRecord::Migration[4.2]
  def change
    add_column :vehicle_journeys, :ignored_stop_area_routing_constraint_ids, :integer, array: true, default: []
  end
end
