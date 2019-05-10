class ChangeCompaniesCustomFieldsValuesType < ActiveRecord::Migration[4.2]
  def change
    reversible do |dir|
      dir.up { change_column :companies, :custom_field_values, 'jsonb USING CAST(custom_field_values AS jsonb)', :default => {} }
      dir.down { change_column :companies, :custom_field_values, 'json USING CAST(custom_field_values AS json)', :default => {} }
    end
  end
end
