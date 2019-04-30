class AddImportComplianceControlSetsToWorkgroups < ActiveRecord::Migration[4.2]
  def change
    add_column :workgroups, :import_compliance_control_set_ids, :integer, array: true, default: []
  end
end
