class AddSyncedAtToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :synced_at, :datetime
  end
end
