class RemoveDeprectedFieldsFromWorkbenches < ActiveRecord::Migration[4.2]
  def change
    remove_column :workbenches, :import_compliance_control_set_id, :bigint
    remove_column :workbenches, :merge_compliance_control_set_id, :bigint
  end
end
