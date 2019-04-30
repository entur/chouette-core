class CreateComplianceCheckSets < ActiveRecord::Migration[4.2]
  def change
    create_table :compliance_check_sets do |t|
      t.references :referential, index: true, foreign_key: true
      t.references :compliance_control_set, index: true, foreign_key: true
      t.references :workbench, index: true, foreign_key: true
      t.string :creator
      t.string :status
      t.references :parent, polymorphic: true, index: true

      t.timestamps null: false
    end
  end
end
