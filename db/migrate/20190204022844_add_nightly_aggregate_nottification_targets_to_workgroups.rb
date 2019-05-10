class AddNightlyAggregateNottificationTargetsToWorkgroups < ActiveRecord::Migration[4.2]
  def change
    add_column :workgroups, :nightly_aggregate_notification_target, :string, default: 'none'
  end
end
