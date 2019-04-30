class AddIntDayTypesToCalendars < ActiveRecord::Migration[4.2]
  def change
    add_column :calendars, :int_day_types, :integer
  end
end
