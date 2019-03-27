class RemoveKeepStopsFromCleanUps < ActiveRecord::Migration[4.2]
  def change
    remove_column :clean_ups, :keep_stops, :boolean
  end
end
