class RenameSecondaryCompaniesColumnFromLines < ActiveRecord::Migration[4.2]
  def change
    rename_column :lines, :secondary_companies_ids, :secondary_company_ids
  end
end
