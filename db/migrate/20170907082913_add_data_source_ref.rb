class AddDataSourceRef < ActiveRecord::Migration[4.2]
  def change
    add_column :routes, :data_source_ref, :string
    add_column :journey_patterns, :data_source_ref, :string
    add_column :routing_constraint_zones, :data_source_ref, :string
    add_column :vehicle_journeys, :data_source_ref, :string
    add_column :time_tables, :data_source_ref, :string
    add_column :footnotes, :data_source_ref, :string
  end
end
