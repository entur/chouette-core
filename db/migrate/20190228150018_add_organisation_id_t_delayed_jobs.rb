class AddOrganisationIdTDelayedJobs < ActiveRecord::Migration[4.2]
  def change
    add_column :delayed_jobs, :organisation_id, :integer, limit: 8
    add_index :delayed_jobs, :organisation_id
  end
end
