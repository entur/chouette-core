class ChangeCrticityTypeForComplianceControl < ActiveRecord::Migration[4.2]
  def change
    change_column :compliance_controls, :criticity, :string
  end
end
