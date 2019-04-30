class AddStifTypeToStopArea < ActiveRecord::Migration[4.2]
  def change
    add_column :stop_areas, :stif_type, :string
  end
end
