class CreateLineReferentialSyncs < ActiveRecord::Migration[4.2]
  def change
    create_table :line_referential_syncs do |t|
      t.references :line_referential, index: true

      t.timestamps
    end
  end
end
