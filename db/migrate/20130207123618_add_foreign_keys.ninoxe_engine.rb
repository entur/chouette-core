# This migration comes from ninoxe_engine (originally 20130204141720)
require "forwardable"

class AddForeignKeys < ActiveRecord::Migration[4.2]
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

  def up
    disable_foreign_key :access_links, :aclk_acpt_fkey
    disable_foreign_key :access_links, :aclk_area_fkey

    add_foreign_key :access_links, :access_points, dependent: :cascade, :name => 'aclk_acpt_fkey'
    add_foreign_key :access_links, :stop_areas, dependent: :cascade, :name => 'aclk_area_fkey'

    disable_foreign_key :access_points, :access_area_fkey
    add_foreign_key :access_points, :stop_areas, dependent: :cascade, name: :access_area_fkey

    disable_foreign_key :connection_links, :colk_endarea_fkey
    disable_foreign_key :connection_links, :colk_startarea_fkey

    add_foreign_key :connection_links, :stop_areas, :on_delete => :cascade, :column => 'arrival_id', :name => 'colk_endarea_fkey'
    add_foreign_key :connection_links, :stop_areas, :on_delete => :cascade, :column => 'departure_id', :name => 'colk_startarea_fkey'

    disable_foreign_key :group_of_lines_lines, :groupofline_group_fkey
    disable_foreign_key :group_of_lines_lines, :groupofline_line_fkey

    add_foreign_key :group_of_lines_lines, :group_of_lines, :on_delete => :cascade, :name => 'groupofline_group_fkey'
    add_foreign_key :group_of_lines_lines, :lines, :on_delete => :cascade,  :name => 'groupofline_line_fkey'


    disable_foreign_key :journey_patterns, :arrival_point_fkey
    disable_foreign_key :journey_patterns, :departure_point_fkey
    disable_foreign_key :journey_patterns, :jp_route_fkey

    add_foreign_key :journey_patterns, :stop_points, :on_delete => :nullify, :column => 'arrival_stop_point_id', :name => 'arrival_point_fkey'
    add_foreign_key :journey_patterns, :stop_points, :on_delete => :nullify, :column => 'departure_stop_point_id', :name => 'departure_point_fkey'
    add_foreign_key :journey_patterns, :routes, :on_delete => :cascade,  :name => 'jp_route_fkey'

    disable_foreign_key :journey_patterns_stop_points, :jpsp_jp_fkey
    disable_foreign_key :journey_patterns_stop_points, :jpsp_stoppoint_fkey

    add_foreign_key :journey_patterns_stop_points, :journey_patterns, :on_delete => :cascade, :name => 'jpsp_jp_fkey'
    add_foreign_key :journey_patterns_stop_points, :stop_points, :on_delete => :cascade,  :name => 'jpsp_stoppoint_fkey'

    disable_foreign_key :lines, :line_company_fkey
    disable_foreign_key :lines, :line_ptnetwork_fkey

    add_foreign_key :lines, :companies, :on_delete => :nullify, :name => 'line_company_fkey'
    add_foreign_key :lines, :networks, :on_delete => :nullify,  :name => 'line_ptnetwork_fkey'

    disable_foreign_key :routes, :route_line_fkey
    add_foreign_key :routes, :lines, :on_delete => :cascade, :name => 'route_line_fkey'


    disable_foreign_key :routing_constraints_lines, :routingconstraint_line_fkey
    disable_foreign_key :routing_constraints_lines, :routingconstraint_stoparea_fkey

    add_foreign_key :routing_constraints_lines, :lines, :on_delete => :cascade, :name => 'routingconstraint_line_fkey'
    add_foreign_key :routing_constraints_lines, :stop_areas, :on_delete => :cascade,  :name => 'routingconstraint_stoparea_fkey'



    disable_foreign_key :stop_areas, :area_parent_fkey
    add_foreign_key :stop_areas, :stop_areas, :on_delete => :nullify, :column => 'parent_id', :name => 'area_parent_fkey'

    disable_foreign_key :stop_areas_stop_areas, :stoparea_child_fkey
    disable_foreign_key :stop_areas_stop_areas, :stoparea_parent_fkey

    add_foreign_key :stop_areas_stop_areas, :stop_areas, :on_delete => :cascade, :column => 'child_id', :name => 'stoparea_child_fkey'
    add_foreign_key :stop_areas_stop_areas, :stop_areas, :on_delete => :cascade, :column => 'parent_id', :name => 'stoparea_parent_fkey'

    disable_foreign_key :stop_points, :stoppoint_area_fkey
    disable_foreign_key :stop_points, :stoppoint_route_fkey

    add_foreign_key :stop_points, :stop_areas, :name => 'stoppoint_area_fkey'
    add_foreign_key :stop_points, :routes, :on_delete => :cascade,  :name => 'stoppoint_route_fkey'

    disable_foreign_key :time_table_dates, :tm_date_fkey
    add_foreign_key :time_table_dates, :time_tables, :on_delete => :cascade,  :name => 'tm_date_fkey'


    disable_foreign_key :time_table_periods, :tm_period_fkey
    add_foreign_key :time_table_periods, :time_tables, :on_delete => :cascade,  :name => 'tm_period_fkey'

    disable_foreign_key :time_tables_vehicle_journeys, :vjtm_tm_fkey
    disable_foreign_key :time_tables_vehicle_journeys, :vjtm_vj_fkey
    add_foreign_key :time_tables_vehicle_journeys, :time_tables, :on_delete => :cascade,  :name => 'vjtm_tm_fkey'
    add_foreign_key :time_tables_vehicle_journeys, :vehicle_journeys, :on_delete => :cascade,  :name => 'vjtm_vj_fkey'


    disable_foreign_key :vehicle_journey_at_stops, :vjas_sp_fkey
    disable_foreign_key :vehicle_journey_at_stops, :vjas_vj_fkey
    add_foreign_key :vehicle_journey_at_stops, :stop_points, :on_delete => :cascade,  :name => 'vjas_sp_fkey'
    add_foreign_key :vehicle_journey_at_stops, :vehicle_journeys, :on_delete => :cascade,  :name => 'vjas_vj_fkey'


    disable_foreign_key :vehicle_journeys, :vj_company_fkey
    disable_foreign_key :vehicle_journeys, :vj_jp_fkey
    disable_foreign_key :vehicle_journeys, :vj_route_fkey

    add_foreign_key :vehicle_journeys, :companies, :on_delete => :nullify,  :name => 'vj_company_fkey'
    add_foreign_key :vehicle_journeys, :journey_patterns, :on_delete => :cascade,  :name => 'vj_jp_fkey'
    add_foreign_key :vehicle_journeys, :routes, :on_delete => :cascade,  :name => 'vj_route_fkey'
  end


  def down
    remove_foreign_key :access_links, :name => :aclk_acpt_fkey
    remove_foreign_key :access_links, :name => :aclk_area_fkey

    remove_foreign_key :access_points, :name => :access_area_fkey

    remove_foreign_key :connection_links, :name => :colk_endarea_fkey
    remove_foreign_key :connection_links, :name => :colk_startarea_fkey

    remove_foreign_key :group_of_lines_lines, :name => :groupofline_group_fkey
    remove_foreign_key :group_of_lines_lines, :name => :groupofline_line_fkey

    remove_foreign_key :journey_patterns, :name => :arrival_point_fkey
    remove_foreign_key :journey_patterns, :name => :departure_point_fkey
    remove_foreign_key :journey_patterns, :name => :jp_route_fkey

    remove_foreign_key :journey_patterns_stop_points, :name => :jpsp_jp_fkey
    remove_foreign_key :journey_patterns_stop_points, :name => :jpsp_stoppoint_fkey

    remove_foreign_key :lines, :name => :line_company_fkey
    remove_foreign_key :lines, :name => :line_ptnetwork_fkey

    remove_foreign_key :routes, :name => :route_line_fkey

    remove_foreign_key :routing_constraints_lines, :name => :routingconstraint_line_fkey
    remove_foreign_key :routing_constraints_lines, :name => :routingconstraint_stoparea_fkey

    remove_foreign_key :stop_areas, :name => :area_parent_fkey

    remove_foreign_key :stop_areas_stop_areas, :name => :stoparea_child_fkey
    remove_foreign_key :stop_areas_stop_areas, :name => :stoparea_parent_fkey

    remove_foreign_key :stop_points, :name => :stoppoint_area_fkey
    remove_foreign_key :stop_points, :name => :stoppoint_route_fkey

    remove_foreign_key :time_table_dates, :name => :tm_date_fkey

    remove_foreign_key :time_table_periods, :name => :tm_period_fkey

    remove_foreign_key :time_tables_vehicle_journeys, :name => :vjtm_tm_fkey
    remove_foreign_key :time_tables_vehicle_journeys, :name => :vjtm_vj_fkey

    remove_foreign_key :vehicle_journey_at_stops, :name => :vjas_sp_fkey
    remove_foreign_key :vehicle_journey_at_stops, :name => :vjas_vj_fkey

    remove_foreign_key :vehicle_journeys, :name => :vj_company_fkey
    remove_foreign_key :vehicle_journeys, :name => :vj_jp_fkey
    remove_foreign_key :vehicle_journeys, :name => :vj_route_fkey

  end
end
