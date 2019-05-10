class CreateComplianceControlBlocks < ActiveRecord::Migration[4.2]
  def change
    create_table :compliance_control_blocks do |t|
      t.string :name
      t.hstore :condition_attributes
      t.references :compliance_control_set, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
