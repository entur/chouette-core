class AddColorToTimetables < ActiveRecord::Migration[4.2]
  def change
    add_column :time_tables, :color, :string
  end
end
