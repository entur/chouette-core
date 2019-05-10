class AddEndDateToCleanUps < ActiveRecord::Migration[4.2]
  def change
    add_column :clean_ups, :end_date, :datetime
  end
end
