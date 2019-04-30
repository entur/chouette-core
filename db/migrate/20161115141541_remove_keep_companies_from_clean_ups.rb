class RemoveKeepCompaniesFromCleanUps < ActiveRecord::Migration[4.2]
  def change
    remove_column :clean_ups, :keep_companies, :boolean
  end
end
