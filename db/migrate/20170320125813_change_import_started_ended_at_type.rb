class ChangeImportStartedEndedAtType < ActiveRecord::Migration[4.2]
  def change
    change_column :imports, :started_at, :datetime
    change_column :imports, :ended_at, :datetime
  end
end
