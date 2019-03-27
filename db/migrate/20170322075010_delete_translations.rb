class DeleteTranslations < ActiveRecord::Migration[4.2]
  def change
    if table_exists?('translations')
      drop_table :translations
    end
  end
end
