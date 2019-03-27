class AddContextToComplianceCheckSets < ActiveRecord::Migration[4.2]
  def change
    add_column :compliance_check_sets, :context, :string
  end
end
