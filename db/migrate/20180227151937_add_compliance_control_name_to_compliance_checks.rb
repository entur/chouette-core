class AddComplianceControlNameToComplianceChecks < ActiveRecord::Migration[4.2]
  def change
    add_column :compliance_checks, :compliance_control_name, :string
  end
end
