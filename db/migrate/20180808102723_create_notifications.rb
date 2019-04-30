class CreateNotifications < ActiveRecord::Migration[4.2]
  def change
    create_table :notifications do |t|
      t.json :payload
      t.string :channel

      t.timestamps null: false
    end
    add_index :notifications, :channel
  end
end
