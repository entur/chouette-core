class RemoveShortNameFromCalendars < ActiveRecord::Migration[4.2]
  def change
    remove_column :calendars, :short_name, :string
  end
end
