class RemoveKeepNetworksFromCleanUps < ActiveRecord::Migration[4.2]
  def change
    remove_column :clean_ups, :keep_networks, :boolean
  end
end
