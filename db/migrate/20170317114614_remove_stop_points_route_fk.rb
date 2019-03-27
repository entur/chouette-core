class RemoveStopPointsRouteFk < ActiveRecord::Migration[4.2]
  def change
    if foreign_keys(:stop_points).any? { |f| f.options[:name] = :stoppoint_route_fkey }
      remove_foreign_key :stop_points, name: :stoppoint_route_fkey
    end
  end
end
