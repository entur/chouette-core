class SetDefaultForCalendarsShared < ActiveRecord::Migration[4.2]
  def change
    change_column_default :calendars, :shared, :false
    Calendar.where(shared: nil).update_all(shared: false)
  end
end
