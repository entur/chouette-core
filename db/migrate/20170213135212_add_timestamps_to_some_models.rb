class AddTimestampsToSomeModels < ActiveRecord::Migration[4.2]
  def up
    models = %i(vehicle_journeys timebands time_tables stop_points stop_areas routing_constraint_zones routes route_sections pt_links networks lines
    journey_patterns group_of_lines connection_links companies access_points access_links)

    models.each do |table|
      unless column_exists?(table, :created_at)
        add_timestamps table
      end

      if column_exists?(table, :creation_time)
        execute "update #{table} set created_at = creation_time"
        remove_column table, :creation_time
      end
    end
  end

  def down

  end
end
