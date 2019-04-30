class AddStartedAtToStopAreaReferentialSyncs < ActiveRecord::Migration[4.2]
  def change
    add_column :stop_area_referential_syncs, :started_at, :datetime
  end
end
