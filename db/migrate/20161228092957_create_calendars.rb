class CreateCalendars < ActiveRecord::Migration[4.2]
  def change
    create_table :calendars do |t|
      t.string :name
      t.string :short_name
      t.daterange :date_ranges, array: true
      t.date :dates, array: true
      t.boolean :shared
      t.belongs_to :organisation, index: true

      t.timestamps
    end
    add_index :calendars, :short_name, unique: true
  end
end
