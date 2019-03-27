class DeleteImportResourceReferentialForeignKey < ActiveRecord::Migration[4.2]
  def change
    remove_foreign_key :import_resources, :referentials
  end
end
