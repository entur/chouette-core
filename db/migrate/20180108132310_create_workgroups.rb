class CreateWorkgroups < ActiveRecord::Migration[4.2]
  def change
    create_table :workgroups do |t|
      t.string :name
      t.integer :line_referential_id,  limit: 8
      t.integer :stop_area_referential_id, limit: 8

      t.timestamps null: false
    end
  end
end
