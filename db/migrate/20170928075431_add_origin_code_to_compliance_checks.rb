class AddOriginCodeToComplianceChecks < ActiveRecord::Migration[4.2]
  def change
    add_column :compliance_checks, :origin_code, :string
  end
end
