class AddStatusToStopArea < ActiveRecord::Migration[4.2]
  def change
    add_column :stop_areas, :status, :string
  end
end
