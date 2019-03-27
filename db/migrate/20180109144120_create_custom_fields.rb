class CreateCustomFields < ActiveRecord::Migration[4.2]
  def change
    create_table :custom_fields do |t|
      t.string :code
      t.string :resource_type
      t.string :name
      t.string :field_type
      t.json :options
      t.bigint :workgroup_id

      t.timestamps null: false
    end
  end
end
