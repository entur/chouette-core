class AddTridentFieldsToRoutingConstraintZone < ActiveRecord::Migration[4.2]
  def change
    add_column :routing_constraint_zones, :objectid, :string, null: false
    add_column :routing_constraint_zones, :object_version, :integer
  end
end
