class UpdateStopAreasConfirmedAtAttribute < ActiveRecord::Migration[4.2]
   def up
    Chouette::StopArea.where(deleted_at: nil).update_all(confirmed_at: Time.now)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
