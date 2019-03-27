class AddWaitingTimeToStopAreas < ActiveRecord::Migration[4.2]
  def change
    add_column :stop_areas, :waiting_time, :integer
  end
end
