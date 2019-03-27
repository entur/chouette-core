class AddAttributesToComplianceCheckSet < ActiveRecord::Migration[4.2]
  def change
    add_column :compliance_check_sets, :current_step_id, :string
    add_column :compliance_check_sets, :string, :string
    add_column :compliance_check_sets, :current_step_progress, :float
    add_column :compliance_check_sets, :name, :string
    add_column :compliance_check_sets, :started_at, :datetime
    add_column :compliance_check_sets, :ended_at, :datetime
  end
end
