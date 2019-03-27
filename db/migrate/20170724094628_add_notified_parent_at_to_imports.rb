class AddNotifiedParentAtToImports < ActiveRecord::Migration[4.2]
  def change
    add_column :imports, :notified_parent_at, :datetime
  end
end
