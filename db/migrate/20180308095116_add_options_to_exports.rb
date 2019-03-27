class AddOptionsToExports < ActiveRecord::Migration[4.2]
  def change
    add_column :exports, :options, :hstore
  end
end
