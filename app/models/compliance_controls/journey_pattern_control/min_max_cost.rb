require_dependency 'compliance_controls/journey_pattern_control/internal_base'

module JourneyPatternControl
  class MinMaxCost < InternalBase
    required_features :costs_in_journey_patterns

    store_accessor :control_attributes, :min
    store_accessor :control_attributes, :max

    enumerize :criticity, in: %i(warning error), scope: true, default: :warning

    def self.compliance_test(compliance_check, journey_pattern)
      journey_pattern.stop_points.order(:position).each_cons(2) do |from, to|
        costs = journey_pattern.costs_between(from, to)
        value = costs[attribute_to_check]&.to_f || 0
        return false if compliance_check.min && value < compliance_check.min.to_f
        return false if compliance_check.max && value > compliance_check.max.to_f
      end
      true
    end

    def self.attribute_to_check
      :distance
    end
  end
end
