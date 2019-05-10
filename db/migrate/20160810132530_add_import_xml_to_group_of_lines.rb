class AddImportXmlToGroupOfLines < ActiveRecord::Migration[4.2]
  def change
    add_column :group_of_lines, :import_xml, :text
  end
end
