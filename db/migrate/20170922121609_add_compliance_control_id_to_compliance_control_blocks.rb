class AddComplianceControlIdToComplianceControlBlocks < ActiveRecord::Migration[4.2]
  def change
    add_reference :compliance_control_blocks, :compliance_control, index: true, foreign_key: true
  end
end
