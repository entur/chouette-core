class ChangeChecksumSourceTypeToText < ActiveRecord::Migration[4.2]
  def tables
    [:vehicle_journey_at_stops, :footnotes, :routing_constraint_zones, :routes, :journey_patterns, :vehicle_journeys, :time_table_dates, :time_table_periods, :time_tables]
  end

  def up
    self.tables.each do |table|
      change_column table, :checksum_source, :text
    end
  end

  def down
    self.tables.each do |table|
      change_column table, :checksum_source, :string
    end
  end
end
