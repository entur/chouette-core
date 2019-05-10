class AddIevEnabledCheckToComplianceChecks < ActiveRecord::Migration[4.2]
  def change
    add_column :compliance_checks, :iev_enabled_check, :boolean, default: true
    add_column :compliance_controls, :iev_enabled_check, :boolean, default: true
  end
end
