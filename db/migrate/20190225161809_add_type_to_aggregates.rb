class AddTypeToAggregates < ActiveRecord::Migration
  def change
    add_column :aggregates, :type, :string
    add_index :aggregates, :type
  end
end
