class AddExcludedDatesToCalendars < ActiveRecord::Migration[4.2]
  def change
    add_column :calendars, :excluded_dates, :date, array: true
  end
end
