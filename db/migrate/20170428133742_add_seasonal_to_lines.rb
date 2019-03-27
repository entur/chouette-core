class AddSeasonalToLines < ActiveRecord::Migration[4.2]
  def change
    add_column :lines, :seasonal, :boolean
  end
end
