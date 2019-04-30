class AddImportXmlToLines < ActiveRecord::Migration[4.2]
  def change
    add_column :lines, :import_xml, :text
  end
end
