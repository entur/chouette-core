class AddCalendarRefToTimeTables < ActiveRecord::Migration[4.2]
  def change
    add_reference :time_tables, :calendar, index: true
  end
end
