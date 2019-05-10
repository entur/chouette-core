class AddStartedAndEndedToAggregates < ActiveRecord::Migration[4.2]
  def change
    add_column :aggregates, :started_at, :datetime
    add_column :aggregates, :ended_at, :datetime
  end
end
