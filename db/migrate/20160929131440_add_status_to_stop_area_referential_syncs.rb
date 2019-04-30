class AddStatusToStopAreaReferentialSyncs < ActiveRecord::Migration[4.2]
  def change
    add_column :stop_area_referential_syncs, :status, :string
  end
end
