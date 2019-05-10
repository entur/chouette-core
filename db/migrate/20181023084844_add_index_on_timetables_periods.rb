class AddIndexOnTimetablesPeriods < ActiveRecord::Migration[4.2]
  def change
    add_index :time_table_periods, [:period_start, :period_end]
  end
end
