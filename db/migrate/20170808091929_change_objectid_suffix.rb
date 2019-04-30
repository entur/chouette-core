class ChangeObjectidSuffix < ActiveRecord::Migration[4.2]
  def tables
    ['routes', 'journey_patterns', 'vehicle_journeys', 'time_tables', 'routing_constraint_zones']
  end

  def up
    self.tables.each do |table|
      execute "UPDATE #{table} SET objectid = (objectid || ':LOC')"
    end
  end

  def down
    self.tables.each do |table|
      execute "UPDATE #{table} SET objectid = replace(objectid, ':LOC', '')"
    end
  end
end
