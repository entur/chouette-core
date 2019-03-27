class RemovePapertrailTables < ActiveRecord::Migration[4.2]
  def change
    drop_table :versions
  end
end
