class AddReferentialsToImportResources < ActiveRecord::Migration[4.2]
  def change
    add_reference :import_resources, :referential, type: :bigint, index: true, foreign_key: true unless column_exists? :import_resources, :referential_id
  end
end
