class AddUrgentToReferentialMetadata < ActiveRecord::Migration[4.2]
  def change
    add_column :referential_metadata, :flagged_urgent_at, :datetime
  end
end
