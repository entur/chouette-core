class AddCustomFieldValuesToStopAreas < ActiveRecord::Migration[4.2]
  def change
    add_column :stop_areas, :custom_field_values, :jsonb
  end
end
