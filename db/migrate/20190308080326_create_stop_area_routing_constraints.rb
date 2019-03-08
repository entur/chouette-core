class CreateStopAreaRoutingConstraints < ActiveRecord::Migration
  def change
    create_table :stop_area_routing_constraints do |t|
      t.integer :from_id, limit: 8
      t.integer :to_id, limit: 8
      t.boolean :both_way

      t.timestamps null: false
    end
    add_index :stop_area_routing_constraints, :from_id
    add_index :stop_area_routing_constraints, :to_id
  end
end
