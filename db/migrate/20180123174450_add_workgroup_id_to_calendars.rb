class AddWorkgroupIdToCalendars < ActiveRecord::Migration[4.2]
   def change
    add_column :calendars, :workgroup_id, :integer, limit: 8
    add_index :calendars, :workgroup_id
  end
end
