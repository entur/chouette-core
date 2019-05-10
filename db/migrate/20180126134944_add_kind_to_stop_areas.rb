class AddKindToStopAreas < ActiveRecord::Migration[4.2]
  def change
    add_column :stop_areas, :kind, :string
    Chouette::StopArea.where.not(kind: :non_commercial).update_all kind: :commercial
  end
end
