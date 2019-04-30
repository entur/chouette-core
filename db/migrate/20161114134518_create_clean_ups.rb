class CreateCleanUps < ActiveRecord::Migration[4.2]
  def change
    create_table :clean_ups do |t|
      t.string :status
      t.datetime :started_at
      t.datetime :ended_at
      t.references :referential, index: true
      t.boolean :keep_lines
      t.boolean :keep_stops
      t.boolean :keep_companies
      t.boolean :keep_networks
      t.boolean :keep_group_of_lines
      t.datetime :expected_date

      t.timestamps
    end
  end
end
