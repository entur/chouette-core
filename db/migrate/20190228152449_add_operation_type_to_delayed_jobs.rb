class AddOperationTypeToDelayedJobs < ActiveRecord::Migration[4.2]
  def change
    add_column :delayed_jobs, :operation_type, :string
  end
end
