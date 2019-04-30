class AddDatesAndTokenToImport < ActiveRecord::Migration[4.2]
  def change
    add_column :imports, :started_at, :date
    add_column :imports, :ended_at, :date
    add_column :imports, :token_download, :string
  end
end
