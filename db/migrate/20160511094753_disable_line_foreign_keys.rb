class DisableLineForeignKeys < ActiveRecord::Migration[4.2]
  def change
    disable_foreign_key :lines, :line_company_fkey
    disable_foreign_key :lines, :line_ptnetwork_fkey
    disable_foreign_key :routing_constraints_lines, :routingconstraint_line_fkey
    disable_foreign_key :routes, :route_line_fkey
    disable_foreign_key :group_of_lines_lines, :groupofline_line_fkey
  end

  def disable_foreign_key(table, name)
    if foreign_key?(table, name)
      remove_foreign_key table, name: name
    end
  end

  def foreign_key?(table, name)
    @connection.foreign_keys(table).any? do |foreign_key|
      foreign_key.options[:name] == name.to_s
    end
  end
end
