class AddTypeToAggregates < ActiveRecord::Migration[4.2]
  def change
    add_column :aggregates, :type, :string
    add_index :aggregates, :type
  end
end
