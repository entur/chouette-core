class ChangeTypeToResourceTypeFromComplianceCheckResources < ActiveRecord::Migration[4.2]
  def change
    rename_column :compliance_check_resources, :type, :resource_type
  end
end
