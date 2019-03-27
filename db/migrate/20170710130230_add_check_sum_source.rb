class AddCheckSumSource < ActiveRecord::Migration[4.2]
  def change
    add_column :vehicle_journey_at_stops, :checksum_source, :string
    add_column :footnotes, :checksum_source, :string
    add_column :routing_constraint_zones, :checksum_source, :string
    add_column :routes, :checksum_source, :string
    add_column :journey_patterns, :checksum_source, :string
    add_column :vehicle_journeys, :checksum_source, :string
    add_column :time_table_dates, :checksum_source, :string
    add_column :time_table_periods, :checksum_source, :string
    add_column :time_tables, :checksum_source, :string
  end
end
