class AddStartedAtToLineReferentialSyncs < ActiveRecord::Migration[4.2]
  def change
    add_column :line_referential_syncs, :started_at, :datetime
  end
end
