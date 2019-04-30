class CreateReferentialSuites < ActiveRecord::Migration[4.2]
  def change
    create_table :referential_suites do |t|
      t.bigint :new_id, index: true
      t.bigint :current_id, index: true

      t.timestamps null: false
    end
  end
end
