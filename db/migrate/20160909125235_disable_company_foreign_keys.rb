class DisableCompanyForeignKeys < ActiveRecord::Migration[4.2]
  def change
    disable_foreign_key :vehicle_journeys, :vj_company_fkey
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
