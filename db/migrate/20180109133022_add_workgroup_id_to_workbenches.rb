class AddWorkgroupIdToWorkbenches < ActiveRecord::Migration[4.2]
  def change
    add_column :workbenches, :workgroup_id, :integer, limit: 8
    add_index :workbenches, :workgroup_id
  end
end
