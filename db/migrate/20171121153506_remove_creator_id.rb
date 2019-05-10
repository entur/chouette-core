class RemoveCreatorId < ActiveRecord::Migration[4.2]
  def change
    [
      'companies', 'connection_links', 'facilities', 'group_of_lines',
      'journey_patterns', 'lines', 'networks', 'pt_links', 'routes', 'routing_constraint_zones',
      'stop_areas', 'stop_points', 'time_tables', 'timebands', 'vehicle_journeys', 'access_links', 'access_points'
    ].each do |table_name|
      remove_column table_name, :creator_id, :string
    end
  end
end
