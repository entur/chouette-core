class ChangeControlAttributesFormatInComplianceControlAndInComplianceCheck < ActiveRecord::Migration[4.2]
  def change

    execute <<-SQL
      CREATE OR REPLACE FUNCTION my_json_to_hstore(json)
            RETURNS hstore
            IMMUTABLE
            STRICT
            LANGUAGE sql
          AS $func$
            SELECT hstore(array_agg(key), array_agg(value))
            FROM   json_each_text($1)
          $func$;
      SQL

    change_column :compliance_controls, :control_attributes, 'hstore USING my_json_to_hstore(control_attributes)'
    change_column :compliance_checks, :control_attributes, 'hstore USING my_json_to_hstore(control_attributes)' 
    execute "DROP FUNCTION my_json_to_hstore(json)"
  end
end
