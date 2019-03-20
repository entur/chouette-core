class ReferentialAudit
  class JourneyPatternStopPoints < Base

    def message record
      "JourneyPattern ##{record.id} has only #{record.stop_points.count} stop_point(s)"
    end

    def find_faulty
      Chouette::JourneyPattern.select('journey_patterns.id, COUNT(stop_points.id)').joins(:stop_points).group('journey_patterns.id').having('COUNT(stop_points.id) < 2')
    end
  end
end
