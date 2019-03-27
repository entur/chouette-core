class AddEndedAtToStopAreaReferentialSyncs < ActiveRecord::Migration[4.2]
  def change
    add_column :stop_area_referential_syncs, :ended_at, :datetime
  end
end
