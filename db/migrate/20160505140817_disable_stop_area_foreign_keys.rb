# coding: utf-8
class DisableStopAreaForeignKeys < ActiveRecord::Migration[4.2]
  def change
    disable_foreign_key :stop_points, :stoppoint_area_fkey
    disable_foreign_key :connection_links, :colk_endarea_fkey
    disable_foreign_key :connection_links, :colk_startarea_fkey
    disable_foreign_key :access_links, :aclk_area_fkey
    disable_foreign_key :access_points, :access_area_fkey

    disable_foreign_key :route_sections, :route_sections_arrival_id_fk
    disable_foreign_key :route_sections, :route_sections_departure_id_fk

    disable_foreign_key :routing_constraints_lines, :routingconstraint_stoparea_fkey
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
