class CreateComplianceChecks < ActiveRecord::Migration[4.2]
  def change
    create_table :compliance_checks do |t|
      t.references :compliance_check_set, index: true, foreign_key: true
      t.references :compliance_check_block, index: true, foreign_key: true
      t.string :type
      t.json :control_attributes
      t.string :name
      t.string :code
      t.integer :criticity
      t.text :comment

      t.timestamps null: false
    end
  end
end
