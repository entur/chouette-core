class AddCreatorToAggregates < ActiveRecord::Migration[4.2]
  def change
    add_column :aggregates, :creator, :string
  end
end
