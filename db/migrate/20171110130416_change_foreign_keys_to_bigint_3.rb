class ChangeForeignKeysToBigint3 < ActiveRecord::Migration[4.2]
  def change
    change_column :compliance_check_resources, :compliance_check_set_id, :bigint
  end
end
