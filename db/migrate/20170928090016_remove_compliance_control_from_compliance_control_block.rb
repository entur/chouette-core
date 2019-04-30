class RemoveComplianceControlFromComplianceControlBlock < ActiveRecord::Migration[4.2]
  def change
    remove_reference :compliance_control_blocks, :compliance_control, index: true, foreign_key: true
  end
end
