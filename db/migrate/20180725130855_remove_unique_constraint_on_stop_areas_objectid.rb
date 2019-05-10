class RemoveUniqueConstraintOnStopAreasObjectid < ActiveRecord::Migration[4.2]
  def change
    remove_index :stop_areas, name: "stop_areas_objectid_key" rescue nil
    add_index "stop_areas", ["objectid", "stop_area_referential_id"], unique: true, using: :btree, name: "stop_areas_objectid_key"
  end
end
