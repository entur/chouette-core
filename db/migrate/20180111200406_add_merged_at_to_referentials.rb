class AddMergedAtToReferentials < ActiveRecord::Migration[4.2]
  def change
    add_column :referentials, :merged_at, :datetime
  end
end
