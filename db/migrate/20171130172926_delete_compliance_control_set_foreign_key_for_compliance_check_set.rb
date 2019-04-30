class DeleteComplianceControlSetForeignKeyForComplianceCheckSet < ActiveRecord::Migration[4.2]

  def up
    remove_foreign_key :compliance_check_sets, :compliance_control_sets
  end

  def down
    add_foreign_key :compliance_check_sets, :compliance_control_sets
  end
end
