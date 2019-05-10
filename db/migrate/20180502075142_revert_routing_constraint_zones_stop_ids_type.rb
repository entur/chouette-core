class RevertRoutingConstraintZonesStopIdsType < ActiveRecord::Migration[4.2]
  def change
    reversible do |dir|
      dir.up { change_column :routing_constraint_zones, :stop_point_ids, :bigint, array: true }
      dir.down { change_column :routing_constraint_zones, :stop_point_ids, :integer, array: true }
    end
  end
end
