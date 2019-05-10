class AlterTableComplianceCheckResultToComplianceCheckMessage < ActiveRecord::Migration[4.2]
  def change
    rename_table :compliance_check_results, :compliance_check_messages
  end
end
