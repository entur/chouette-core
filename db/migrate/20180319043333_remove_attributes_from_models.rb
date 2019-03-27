class RemoveAttributesFromModels < ActiveRecord::Migration[4.2]
  def change
    remove_column "vehicle_journeys", "status_value"
    remove_column "journey_patterns", "section_status"
  end
end
