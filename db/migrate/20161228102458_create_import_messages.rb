class CreateImportMessages < ActiveRecord::Migration[4.2]
  def change
    create_table :import_messages do |t|
      t.integer :criticity
      t.string :message_key
      t.hstore :message_attributs
      t.references :import, index: true
      t.references :resource, index: true

      t.timestamps
    end
  end
end
