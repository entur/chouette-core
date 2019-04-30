class AddLimitToExportId < ActiveRecord::Migration[4.2]
  def change
    change_column :publication_api_sources, :export_id, :integer, limit: 8
  end
end
