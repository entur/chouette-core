class AddStatusToPublications < ActiveRecord::Migration[4.2]
  def change
    add_column :publications, :status, :string
    add_column :publications, :started_at, :datetime
    add_column :publications, :ended_at, :datetime
  end
end
