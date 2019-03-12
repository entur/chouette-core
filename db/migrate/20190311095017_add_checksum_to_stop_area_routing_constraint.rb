class AddChecksumToStopAreaRoutingConstraint < ActiveRecord::Migration
  def change
    add_column :stop_area_routing_constraints, :checksum, :string
    add_column :stop_area_routing_constraints, :checksum_source, :text
  end
end
