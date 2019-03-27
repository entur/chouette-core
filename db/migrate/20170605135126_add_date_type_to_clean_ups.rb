class AddDateTypeToCleanUps < ActiveRecord::Migration[4.2]
  def change
    add_column :clean_ups, :date_type, :string
  end
end
