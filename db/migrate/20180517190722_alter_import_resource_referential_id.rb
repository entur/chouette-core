class AlterImportResourceReferentialId < ActiveRecord::Migration[4.2]
  def change
    change_column :import_resources, :referential_id, :bigint
  end
end
