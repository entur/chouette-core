class AddImportXmlToNetworks < ActiveRecord::Migration[4.2]
  def change
    add_column :networks, :import_xml, :text
  end
end
