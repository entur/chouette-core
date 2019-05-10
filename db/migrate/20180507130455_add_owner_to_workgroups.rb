class AddOwnerToWorkgroups < ActiveRecord::Migration[4.2]
  def change
    add_column :workgroups, :owner_id, :bigint
    add_column :workbenches, :owner_compliance_control_set_ids, :hstore
    remove_column :workgroups, :import_compliance_control_set_ids
  end
end
