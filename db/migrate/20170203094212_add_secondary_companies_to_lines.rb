class AddSecondaryCompaniesToLines < ActiveRecord::Migration[4.2]
  def change
    add_column :lines, :secondary_companies_ids, :integer, array: true
    add_index :lines, :secondary_companies_ids, using: :gin
  end
end
