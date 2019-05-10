class ChangePeriodeFromReferentialMetadata < ActiveRecord::Migration[4.2]
  def up
    if column_exists? :referential_metadata, :periode
      remove_column :referential_metadata, :periode, :daterange
    end
    add_column :referential_metadata, :periodes, :daterange, array: true
  end

  def down
    remove_column :referential_metadata, :periodes, :daterange
  end
end
