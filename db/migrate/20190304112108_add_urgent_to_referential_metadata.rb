class AddUrgentToReferentialMetadata < ActiveRecord::Migration
  def change
    add_column :referential_metadata, :flagged_urgent_at, :datetime
  end
end
