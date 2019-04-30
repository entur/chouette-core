class RenameBusinessCalendarsToPurchaseWindows < ActiveRecord::Migration[4.2]
  def change
    rename_table :business_calendars, :purchase_windows
  end
end
