class RenameColumnexpectedDateFromCleanups < ActiveRecord::Migration[4.2]
  def up
    rename_column :clean_ups, :expected_date, :begin_date
  end

  def down
    rename_column :clean_ups, :begin_date, :expected_date
  end
end
