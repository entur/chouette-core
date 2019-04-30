class SetCodeUiquenessInComplianceControl < ActiveRecord::Migration[4.2]
  def change
    add_index :compliance_controls, [:code, :compliance_control_set_id], unique: true
  end
end
