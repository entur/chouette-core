class ChangeBeginDateFromCleanUps < ActiveRecord::Migration[4.2]
  def up
    change_column :clean_ups, :begin_date, :date
  end

  def down
    change_column :clean_ups, :begin_date, :datetime
  end
end
