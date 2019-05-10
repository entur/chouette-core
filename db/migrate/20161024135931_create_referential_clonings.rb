class CreateReferentialClonings < ActiveRecord::Migration[4.2]
  def change
    create_table :referential_clonings do |t|
      t.string :status
      t.datetime :started_at
      t.datetime :ended_at
      t.references :source_referential, index: true
      t.references :target_referential, index: true

      t.timestamps
    end
  end
end
