class AddSyncedAtToOrganisations < ActiveRecord::Migration[4.2]
  def change
    add_column :organisations, :synced_at, :datetime
  end
end
