class AddExportIdToPublicationApiSources < ActiveRecord::Migration[4.2]
  def change
    PublicationApiSource.delete_all
    add_column :publication_api_sources, :export_id, :int, limit: 8
    remove_column :publication_api_sources, :file, :string
  end
end
