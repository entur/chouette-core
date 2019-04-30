class CreateComplianceControlSets < ActiveRecord::Migration[4.2]
  def change
    create_table :compliance_control_sets do |t|
      t.string :name
      t.references :organisation, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
