class RemoveStringToComplianceCheckSet < ActiveRecord::Migration[4.2]
  def change
    remove_column :compliance_check_sets, :string, :string
  end
end
