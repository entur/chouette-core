class AddAggregatedReferentialIdToWorkbenches < ActiveRecord::Migration[4.2]
  def change
    add_column :workbenches, :locked_referential_to_aggregate_id, :int, limit: 8
    add_index :workbenches, :locked_referential_to_aggregate_id
  end
end
