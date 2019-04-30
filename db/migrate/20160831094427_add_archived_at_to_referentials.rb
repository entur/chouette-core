class AddArchivedAtToReferentials < ActiveRecord::Migration[4.2]
  def change
    add_column :referentials, :archived_at, :datetime
  end
end
