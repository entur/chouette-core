class AddCreatedFromToTimeTables < ActiveRecord::Migration[4.2]
  def change
    add_reference :time_tables, :created_from, index: true
  end
end
