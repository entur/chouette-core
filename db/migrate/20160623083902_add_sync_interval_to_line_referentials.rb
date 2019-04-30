class AddSyncIntervalToLineReferentials < ActiveRecord::Migration[4.2]
  def change
    add_column :line_referentials, :sync_interval, :int, :default => 1
  end
end
