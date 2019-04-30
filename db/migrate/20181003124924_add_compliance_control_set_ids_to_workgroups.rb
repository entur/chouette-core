class AddComplianceControlSetIdsToWorkgroups < ActiveRecord::Migration[4.2]
  def change
    add_column :workgroups, :compliance_control_set_ids, :hstore
  end
end
