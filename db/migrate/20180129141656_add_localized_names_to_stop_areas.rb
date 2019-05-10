class AddLocalizedNamesToStopAreas < ActiveRecord::Migration[4.2]
  def change
    add_column :stop_areas, :localized_names, :jsonb
  end
end
