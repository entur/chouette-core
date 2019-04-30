class CreateNewComplianceCheckResults < ActiveRecord::Migration[4.2]
  def change
    drop_table :compliance_check_results if table_exists? :compliance_check_results
    create_table :compliance_check_results do |t|
      t.references :compliance_check, index: true, foreign_key: true
      t.references :compliance_check_resource, index: true, foreign_key: true
      t.string :message_key
      t.hstore :message_attributes
      t.hstore :resource_attributes

      t.timestamps null: false
    end
  end
end
