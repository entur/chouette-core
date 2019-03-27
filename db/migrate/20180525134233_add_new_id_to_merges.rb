class AddNewIdToMerges < ActiveRecord::Migration[4.2]
  def change
    add_column :merges, :new_id, :integer, limit: 8
  end
end
