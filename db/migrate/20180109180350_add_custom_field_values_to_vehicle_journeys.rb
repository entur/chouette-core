class AddCustomFieldValuesToVehicleJourneys < ActiveRecord::Migration[4.2]
  def change
    add_column :vehicle_journeys, :custom_field_values, :jsonb, default: {}
  end
end
