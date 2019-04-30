class CreateJoinTablePurchaseWindowsVehicleJourneys < ActiveRecord::Migration[4.2]
  def change
    create_join_table :purchase_windows, :vehicle_journeys do |t|
      t.integer :purchase_window_id, limit: 8
      t.integer :vehicle_journey_id, limit: 8
    end
  end
end
