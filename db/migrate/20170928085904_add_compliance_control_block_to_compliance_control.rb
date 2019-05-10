class AddComplianceControlBlockToComplianceControl < ActiveRecord::Migration[4.2]
  def change
    add_reference :compliance_controls, :compliance_control_block, index: true, foreign_key: true
  end
end
