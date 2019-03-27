class AddStatusToLineReferentialSyncs < ActiveRecord::Migration[4.2]
  def change
    add_column :line_referential_syncs, :status, :string
  end
end
