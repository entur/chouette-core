class AddOutputToWorkgroups < ActiveRecord::Migration[4.2]
  def change
    add_column :workgroups, :output_id, :integer, limit: 8
    Workgroup.find_each &:save
  end
end
