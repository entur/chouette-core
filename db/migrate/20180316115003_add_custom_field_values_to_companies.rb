class AddCustomFieldValuesToCompanies < ActiveRecord::Migration[4.2]
  def change
    add_column :companies, :custom_field_values, :json
  end
end
