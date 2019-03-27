class AddConfirmedAtToStopAreas < ActiveRecord::Migration[4.2]
  def change
    add_column :stop_areas, :confirmed_at, :datetime
  end
end
