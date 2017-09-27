module Support
  module Permissions extend self

    def all_permissions
      @__all_permissions__ ||= _destructive_permissions << 'sessions.create'
    end

    private

    def _destructive_permissions
      _permitted_resources.product( %w{create destroy update} ).map{ |model_action| model_action.join('.') }
    end

    def _permitted_resources
      %w[
      api_keys
      access_points
      connection_links
      calendars
      footnotes
      imports
      journey_patterns
      referentials
      routes
      routing_constraint_zones
      time_tables
      vehicle_journeys
      compliance_controls
      ]
    end
  end
end
