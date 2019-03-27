class AddComplianceCheckSetToComplianceCheckMessage < ActiveRecord::Migration[4.2]
  def change
    add_reference :compliance_check_messages, :compliance_check_set, index: true, foreign_key: true
  end
end
