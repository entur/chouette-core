class AddImportXmlToStopArea < ActiveRecord::Migration[4.2]
  def change
    add_column :stop_areas, :import_xml, :text
  end
end
