class AddOtherTridentFieldsToRoutingConstraintZone < ActiveRecord::Migration[4.2]
  def change
    add_column :routing_constraint_zones, :creation_time, :datetime
    add_column :routing_constraint_zones, :creator_id, :string
  end
end
