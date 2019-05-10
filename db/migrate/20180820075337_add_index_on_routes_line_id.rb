class AddIndexOnRoutesLineId < ActiveRecord::Migration[4.2]
  def change
    add_index :routes, :line_id
  end
end
