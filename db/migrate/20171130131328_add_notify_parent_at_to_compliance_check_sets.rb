class AddNotifyParentAtToComplianceCheckSets < ActiveRecord::Migration[4.2]
  def change
    add_column :compliance_check_sets, :notified_parent_at, :datetime
  end
end
