module Chouette
  class VehicleJourneyAtStopsDayOffset
    def initialize(at_stops)
      @at_stops = at_stops
    end

    def calculate!(force_reset=false)
      offset = 0
      @at_stops.select{|s| s.arrival_time.present? && s.departure_time.present? }.inject(nil) do |prior_stop, stop|
        if prior_stop.nil?
          stop.departure_day_offset = 0
          stop.arrival_day_offset = 0
          next stop
        end

        stop_arrival_time = stop.arrival_time_with_zone
        prior_stop_departure_time = prior_stop.departure_time_with_zone

        # Compare Time with Zone 23:00 +001 with 00:05 +002
        if stop_arrival_time < prior_stop_departure_time
          offset += 1
        end

        unless force_reset
          offset = [stop.arrival_day_offset, offset].max
        end

        stop.arrival_day_offset = offset

        # Compare '23:00' with '00:05' for example
        if stop.departure_local < stop.arrival_local
          offset += 1
        end

        unless force_reset
          offset = [stop.departure_day_offset, offset].max
        end
        stop.departure_day_offset = offset

        stop
      end
    end

    def save
      @at_stops.each do |at_stop|
        attrs = %i[departure_day_offset arrival_day_offset]
        at_stop.save if attrs.any? { |attr| at_stop.send("#{attr}_changed?")}
      end
    end

    def update(force_reset=false)
      calculate!(force_reset)
      save
    end
  end
end
