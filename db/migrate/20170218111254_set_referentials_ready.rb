class SetReferentialsReady < ActiveRecord::Migration[4.2]
  def up
    Referential.update_all ready: true
  end

  def down
  end
end
