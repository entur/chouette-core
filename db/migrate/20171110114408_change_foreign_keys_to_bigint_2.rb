class ChangeForeignKeysToBigint2 < ActiveRecord::Migration[4.2]
  def change
    change_column :api_keys, :organisation_id, :bigint
    change_column :compliance_check_blocks, :compliance_check_set_id, :bigint
    change_column :compliance_check_messages, :compliance_check_id, :bigint
    change_column :compliance_check_messages, :compliance_check_resource_id, :bigint
    change_column :compliance_check_messages, :compliance_check_set_id, :bigint
    change_column :compliance_check_sets, :referential_id, :bigint
    change_column :compliance_check_sets, :compliance_control_set_id, :bigint
    change_column :compliance_check_sets, :workbench_id, :bigint
    change_column :compliance_check_sets, :parent_id, :bigint
    change_column :compliance_checks, :compliance_check_set_id, :bigint
    change_column :compliance_checks, :compliance_check_block_id, :bigint
    change_column :compliance_control_blocks, :compliance_control_set_id, :bigint
    change_column :compliance_control_sets, :organisation_id, :bigint
    change_column :compliance_controls, :compliance_control_set_id, :bigint
    change_column :compliance_controls, :compliance_control_block_id, :bigint
    change_column :time_tables, :created_from_id, :bigint
  end
end
