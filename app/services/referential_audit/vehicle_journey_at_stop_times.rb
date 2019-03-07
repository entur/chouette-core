class ReferentialAudit
  class VehicleJourneyAtStopTimes < Base
    def find_faulty
      Chouette::VehicleJourneyAtStop.where(departure_time: nil, arrival_time: nil).select('DISTINCT(vehicle_journey_id)')
    end

    def message record
      "VehicleJourney ##{record.vehicle_journey_id} has a stop with both times unset"
    end
  end
end
