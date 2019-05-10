class ChangeCriticityInComplianceCheckToString < ActiveRecord::Migration[4.2]
  def change
    change_column :compliance_checks, :criticity, :string
  end
end
