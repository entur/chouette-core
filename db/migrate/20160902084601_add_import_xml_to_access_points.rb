class AddImportXmlToAccessPoints < ActiveRecord::Migration[4.2]
  def change
    add_column :access_points, :import_xml, :text
  end
end
