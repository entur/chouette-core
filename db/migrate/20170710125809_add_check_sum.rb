class AddCheckSum < ActiveRecord::Migration[4.2]
  def change
    add_column :vehicle_journey_at_stops, :checksum, :string
    add_column :footnotes, :checksum, :string
    add_column :routing_constraint_zones, :checksum, :string
    add_column :routes, :checksum, :string
    add_column :journey_patterns, :checksum, :string
    add_column :vehicle_journeys, :checksum, :string
    add_column :time_table_dates, :checksum, :string
    add_column :time_table_periods, :checksum, :string
    add_column :time_tables, :checksum, :string
  end
end
