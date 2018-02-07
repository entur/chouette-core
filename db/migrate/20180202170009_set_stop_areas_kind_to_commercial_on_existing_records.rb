class SetStopAreasKindToCommercialOnExistingRecords < ActiveRecord::Migration
  def up
    Chouette::StopArea
      .where('kind != ? or kind is null', :non_commercial)
      .update_all(kind: :commercial)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
