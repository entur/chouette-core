class AddNightlyAggregatedAtToWorkgroups < ActiveRecord::Migration[4.2]
  def change
    add_column :workgroups, :nightly_aggregated_at, :datetime
  end
end
