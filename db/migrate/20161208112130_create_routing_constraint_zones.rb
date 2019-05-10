class CreateRoutingConstraintZones < ActiveRecord::Migration[4.2]
  def change
    create_table :routing_constraint_zones do |t|
      t.string :name
      t.integer :stop_area_ids, array: true
      t.belongs_to :line, index: true

      t.timestamps
    end
  end
end
