class AddOriginCodeToComplianceControls < ActiveRecord::Migration[4.2]
  def change
    add_column :compliance_controls, :origin_code, :string
  end
end
