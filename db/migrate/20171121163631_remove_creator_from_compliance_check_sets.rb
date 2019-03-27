class RemoveCreatorFromComplianceCheckSets < ActiveRecord::Migration[4.2]
  def change
    remove_column :compliance_check_sets, :creator, :string
  end
end
