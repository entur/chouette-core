class AddStatusToComplianceCheckMessage < ActiveRecord::Migration[4.2]
  def change
    add_column :compliance_check_messages, :status, :string
  end
end
