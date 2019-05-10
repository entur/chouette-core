class AddNightlyAggregateFieldsToWorkgroup < ActiveRecord::Migration[4.2]
  def change
    add_column :workgroups, :nightly_aggregate_time, :time, default: "00:00"
    add_column :workgroups, :nightly_aggregate_enabled, :boolean, default: false
  end
end
