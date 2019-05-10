class CreateBusinessCalendars < ActiveRecord::Migration[4.2]
  def change
    create_table :business_calendars do |t|
      t.string :name
      t.string :short_name
      t.string :color
      t.daterange :date_ranges, array: true
      t.date :dates, array: true
      t.belongs_to :organisation, index: true

      t.timestamps null: false
    end
  end
end
