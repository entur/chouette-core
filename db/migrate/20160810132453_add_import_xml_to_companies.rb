class AddImportXmlToCompanies < ActiveRecord::Migration[4.2]
  def change
    add_column :companies, :import_xml, :text
  end
end
