class DropTableRuleParameterSets < ActiveRecord::Migration[4.2]
  def change
    drop_table :rule_parameter_sets
  end
end
