class AddEndedAtToLineReferentialSyncs < ActiveRecord::Migration[4.2]
  def change
    add_column :line_referential_syncs, :ended_at, :datetime
  end
end
