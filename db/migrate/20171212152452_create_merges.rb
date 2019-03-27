class CreateMerges < ActiveRecord::Migration[4.2]
  def change
    create_table :merges do |t|
      t.bigint :workbench_id, index: true, foreign_key: true
      t.bigint :referential_ids, array: true

      t.string :creator
      t.string :status

      t.datetime :started_at
      t.datetime :ended_at

      t.timestamps null: false
    end
  end
end
