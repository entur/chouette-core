class AddDefaultToVehicleJourneyAtStopsArrivalAndDepartureDayOffset < ActiveRecord::Migration[4.2]
  def change
    change_column_default :vehicle_journey_at_stops, :arrival_day_offset, 0
    change_column_default :vehicle_journey_at_stops, :departure_day_offset, 0
  end
end
