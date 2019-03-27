class ChangeObjectVersionColumnType < ActiveRecord::Migration[4.2]
  @@tables_to_change = %i(access_links access_points companies connection_links facilities group_of_lines journey_patterns lines networks
    pt_links route_sections routes routing_constraint_zones stop_areas stop_points time_tables timebands vehicle_journeys)

  def up
    @@tables_to_change.each { |table| change_column table, :object_version, :bigint }
  end

  def down
    @@tables_to_change.each { |table| change_column table, :object_version, :integer }
  end
end
