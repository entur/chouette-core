class DeleteReferentialForeignKeyForComplianceCheckSet < ActiveRecord::Migration[4.2]
  def up
    remove_foreign_key :compliance_check_sets, :referentials
  end

  def down
    add_foreign_key :compliance_check_sets, :referentials
  end
end
