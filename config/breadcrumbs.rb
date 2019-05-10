crumb :root do
end

crumb :workbench do |workbench|
  link workbench.name, workbench_path(workbench)
  parent :workgroup, workbench.workgroup
end

crumb :workgroups do |workgroup|
  link Workgroup.t, workgroups_path()
end

crumb :workgroup do |workgroup, display_parent|
  link workgroup.name, workgroup_path(workgroup)
  parent :workgroups if display_parent
end

crumb :workbench_configure do |workbench|
  link I18n.t('workbenches.edit.title'), edit_workbench_path(workbench)
  parent :workbench, workbench
end

crumb :workbench_output do |workbench|
  link I18n.t('workbench_outputs.show.title'), workbench_output_path(workbench)
  parent :workbench, mutual_workbench(workbench)
end

crumb :workgroup_output do |workgroup|
  link 'layouts.navbar.workbench_outputs.workgroup'.t, workgroup_output_path(workgroup)
end

crumb :merges do |workbench|
  link I18n.t('merges.index.title'), workbench_output_path(workbench)
  parent :workbench, workbench
end

crumb :merge do |merge|
  link breadcrumb_name(merge), workbench_merge_path(merge.workbench, merge)
  parent :merges, merge.workbench
end

crumb :publications_menu do |workgroup|
  link 'layouts.navbar.publications.subtitle'.t
  parent workgroup
end

crumb :publication_apis do |workgroup|
  link PublicationApi.t, workgroup_publication_apis_path(workgroup)
  parent :publications_menu, workgroup
end

crumb :publication_api do |publication_api|
  link publication_api.name, [publication_api.workgroup, publication_api]
  parent :publication_apis, publication_api.workgroup
end

crumb :new_publication_api_key do |publication_api|
  link 'publication_api_keys.actions.new'.t
  parent publication_api
end

crumb :publication_api_key do |publication_api_key|
  link publication_api_key.name
  parent publication_api_key.publication_api
end

crumb :new_publication_api do |workgroup|
  link 'publication_apis.actions.new'.t
  parent :publication_apis, workgroup
end

crumb :publication_setups do |workgroup|
  link PublicationSetup.t, workgroup_publication_setups_path(workgroup)
  parent :publications_menu, workgroup
end

crumb :publication do |publication|
  link publication.pretty_date, [publication.publication_setup.workgroup, publication.publication_setup, publication]
  parent publication.publication_setup
end

crumb :publication_setup do |publication_setup|
  link publication_setup.name, [publication_setup.workgroup, publication_setup]
  parent :publication_setups, publication_setup.workgroup
end

crumb :new_publication_setup do |workgroup|
  link 'publication_setups.actions.new'.t
  parent :publication_setups, workgroup
end

crumb :aggregates do |workgroup|
  link 'layouts.navbar.workbench_outputs.workgroup'.t, workgroup_output_path(workgroup)
end

crumb :aggregate do |aggregate|
  link breadcrumb_name(aggregate), workgroup_aggregate_path(aggregate.workgroup, aggregate)
  parent :aggregates, aggregate.workgroup
end

crumb :referential do |referential|
  link breadcrumb_name(referential), referential_path(referential)
  if referential.workbench
    parent :workbench, mutual_workbench(referential.workbench || referential.workgroup.workbenches.last)
  else
    parent :workgroup_output, referential.workgroup
  end
end

crumb :referentials do |referential|
  link I18n.t('referentials.index.title'), workbench_path(current_workbench)
  parent :workbench, mutual_workbench(current_workbench)
end

crumb :referential_companies do |referential|
  link I18n.t('companies.index.title'), referential_companies_path(referential)
  parent :referential, referential
end

crumb :referential_company do |referential, company|
  link breadcrumb_name(company), referential_company_path(referential, company)
  parent :referential_companies, referential
end

crumb :referential_networks do |referential|
  link I18n.t('networks.index.title'), referential_networks_path
  parent :referential, referential
end

crumb :referential_network do |referential, network|
  link  breadcrumb_name(network), referential_network_path(referential, network)
  parent :referential_networks, referential
end

crumb :referential_group_of_lines do |referential|
  link I18n.t('group_of_lines.index.title'), referential_networks_path(referential)
  parent :referential, referential
end

crumb :referential_group_of_line do |referential, group_of_line|
  link  breadcrumb_name(group_of_line), referential_group_of_line_path(referential, group_of_line)
  parent :referential_group_of_lines, referential
end

crumb :referential_vehicle_journeys do |referential|
  link I18n.t('referential_vehicle_journeys.index.title'), referential_vehicle_journeys_path(referential)
  parent :referential, referential
end

crumb :time_tables do |referential|
  link I18n.t('time_tables.index.title'), referential_time_tables_path(referential)
  parent :referential, referential
end

crumb :time_table do |referential, time_table|
  link breadcrumb_name(time_table, 'comment'), referential_time_table_path(referential, time_table)
  parent :time_tables, referential
end

crumb :compliance_check_sets do |ccset_parent|
  link I18n.t('compliance_check_sets.index.title'), workbench_compliance_check_sets_path(ccset_parent)
  if ccset_parent.is_a?(Workbench)
    parent :workbench, ccset_parent
  else
    parent :imports_parent, ccset_parent
  end
end

crumb :compliance_check_set do |ccset_parent, compliance_check_set|
  link breadcrumb_name(compliance_check_set), [ccset_parent, compliance_check_set]
  parent :compliance_check_sets, ccset_parent
end

crumb :compliance_check do |cc_set_parent, compliance_check|
  link breadcrumb_name(compliance_check), [cc_set_parent, compliance_check.compliance_check_set, compliance_check]
  parent :compliance_check_set_executed, cc_set_parent, compliance_check.compliance_check_set
end

crumb :compliance_check_set_executed do |cc_set_parent, compliance_check_set|
  link I18n.t('compliance_check_sets.executed.title', name: compliance_check_set.name), [:executed, cc_set_parent, compliance_check_set]
  parent :compliance_check_sets, cc_set_parent
end

crumb :imports_parent do |imports_parent|
  if imports_parent.is_a? Workgroup
    link Workgroup.ts, [imports_parent]
  else
    link imports_parent.name, [imports_parent]
  end
end

crumb :imports do |imports_parent|
  link I18n.t('imports.index.title'), [imports_parent, :imports]
  parent :imports_parent, imports_parent
end

crumb :exports do |workbench|
  link I18n.t('exports.index.title'), workbench_exports_path(workbench)
  parent :workbench, workbench
end

crumb :import do |imports_parent, import|
  link breadcrumb_name(import), [imports_parent, import]
  parent :imports, imports_parent
end

crumb :netex_import do |imports_parent, netex_import|
  link breadcrumb_name(netex_import), [imports_parent, netex_import]
  parent :import, imports_parent, netex_import.parent
end

crumb :gtfs_import do |imports_parent, gtfs_import|
  link breadcrumb_name(gtfs_import), [imports_parent, gtfs_import]
  parent :import, imports_parent, gtfs_import.parent
end

crumb :export do |export_parent, export|
  if export_parent.is_a?(Workbench)
    link breadcrumb_name(export), workbench_export_path(export_parent, export)
    parent :exports, export_parent
  else
    link breadcrumb_name(export), [export_parent.publication_setup.workgroup, export_parent.publication_setup, export_parent, export]
    parent export_parent
  end
end

crumb :import_resources do |import, import_resources|
  link I18n.t('import.resources.index.title'), workbench_import_import_resources_path(import.workbench, import.parent)
  parent :import, import.workbench, import.parent
end

crumb :import_resource do |import_resource|
  link I18n.t('import.resources.index.title'), workbench_import_import_resource_path(import_resource.root_import.workbench, import_resource.root_import, import_resource)
  parent :import, import_resource.root_import.workbench, import_resource.root_import
end

crumb :user do |user|
  link user.name, organisation_user_path(user)
  parent user.organisation
end

crumb :edit_user do |user|
  link 'users.actions.edit'.t
  parent user
end

crumb :new_invitation do |organisation|
  link 'actions.invite_user'.t
  parent organisation
end

crumb :organisation do |organisation|
  link breadcrumb_name(organisation), organisation_path()
end

crumb :compliance_control_sets do
  link I18n.t('compliance_control_sets.index.title'), compliance_control_sets_path
end

crumb :compliance_control_set do |compliance_control_set|
  link breadcrumb_name(compliance_control_set), compliance_control_set_path(compliance_control_set)
  parent :compliance_control_sets
end

crumb :compliance_control do |compliance_control|
  link breadcrumb_name(compliance_control), compliance_control_set_compliance_control_path(compliance_control.compliance_control_set, compliance_control)
  parent :compliance_control_set, compliance_control.compliance_control_set
end

crumb :stop_area_referential do |stop_area_referential|
  link I18n.t('stop_area_referentials.show.title'), stop_area_referential_path(stop_area_referential)
end

crumb :stop_areas do |stop_area_referential|
  link I18n.t('stop_areas.index.title'), stop_area_referential_stop_areas_path(stop_area_referential)
end

crumb :stop_area_providers do |stop_area_referential|
  link StopAreaProvider.t, stop_area_referential_stop_area_providers_path(stop_area_referential)
end

crumb :stop_area_provider do |stop_area_referential, stop_area_provider|
  link stop_area_provider.name, stop_area_referential_stop_area_provider_path(stop_area_referential, stop_area_provider)
  parent :stop_area_providers, stop_area_referential
end

crumb :stop_area_routing_constraints do |stop_area_referential|
  link StopAreaRoutingConstraint.t, [stop_area_referential, :stop_area_routing_constraints]
  parent stop_area_referential
end

crumb :stop_area_routing_constraint do |stop_area_routing_constraint|
  link stop_area_routing_constraint.name, [stop_area_routing_constraint.stop_area_referential, stop_area_routing_constraint]
  parent :stop_area_routing_constraints, stop_area_routing_constraint.stop_area_referential
end

crumb :stop_area do |stop_area_referential, stop_area|
  link breadcrumb_name(stop_area), stop_area_referential_stop_area_path(stop_area_referential, stop_area)
  parent :stop_areas, stop_area_referential
end

crumb :line_referential do |line_referential|
  link I18n.t('line_referentials.show.title'), line_referential_path(line_referential)
end

crumb :companies do |line_referential|
  link I18n.t('companies.index.title'), line_referential_companies_path(line_referential)
end

crumb :company do |company|
  link breadcrumb_name(company), line_referential_company_path(company.line_referential, company)
  parent :companies, company.line_referential
end

crumb :networks do |line_referential|
  link I18n.t('networks.index.title'), line_referential_networks_path(line_referential)
end

crumb :network do |network|
  link breadcrumb_name(network), line_referential_network_path(network.line_referential, network)
  parent :networks, network.line_referential
end

crumb :group_of_lines do |line_referential|
  link I18n.t('group_of_lines.index.title'), line_referential_group_of_lines_path(line_referential)
end

crumb :group_of_line do |group_of_line|
  link breadcrumb_name(group_of_line), line_referential_group_of_line_path(group_of_line.line_referential, group_of_line)
  parent :group_of_lines, group_of_line.line_referential
end

crumb :lines do |line_referential|
  link I18n.t('lines.index.title'), line_referential_lines_path
end

crumb :line do |line|
  link breadcrumb_name(line), line_referential_line_path(line.line_referential, line)
  parent :lines, line.line_referential
end

crumb :purchase_windows do |referential|
  link I18n.t('purchase_windows.index.title'), referential_purchase_windows_path(referential)
  parent :referential, referential
end

crumb :purchase_window do |referential, purchase_window|
  link breadcrumb_name(purchase_window), referential_purchase_window_path(referential, purchase_window)
  parent :purchase_windows, referential
end

crumb :calendars do |workgroup|
  link I18n.t('calendars.index.title'), workgroup_calendars_path(workgroup)
end

crumb :calendar do |workgroup, calendar|
  link breadcrumb_name(calendar), workgroup_calendar_path(workgroup, calendar)
  parent :calendars, workgroup
end

crumb :referential_line do |referential, line|
  link breadcrumb_name(line), referential_line_path(referential, line)
  parent :referential, referential
end

crumb :footnotes do |referential, line|
  link I18n.t('footnotes.index.title'), referential_line_footnotes_path(referential, line)
  parent :referential_line, referential, line
end

crumb :routing_constraint_zones do |referential, line|
  link I18n.t('routing_constraint_zones.index.title'), referential_line_routing_constraint_zones_path(referential, line)
  parent :referential_line, referential, line
end

crumb :routing_constraint_zone do |referential, line, routing_constraint_zone|
  link breadcrumb_name(routing_constraint_zone), referential_line_routing_constraint_zone_path(referential, line, routing_constraint_zone)
  parent :routing_constraint_zones, referential, line
end

crumb :route do |referential, route|
  link I18n.t('routes.index.title', route: route.name), referential_line_route_path(referential, route.line, route)
  parent :referential_line, referential, route.line
end

crumb :journey_patterns do |referential, route|
  link I18n.t('journey_patterns.index.title', route: route.name), referential_line_route_journey_patterns_collection_path(referential, route.line, route)
  parent :route, referential, route
end

crumb :vehicle_journeys do |referential, route|
  link I18n.t('vehicle_journeys.index.title', route: route.name), referential_line_route_vehicle_journeys_path(referential, route.line, route)
  parent :route, referential, route
end

crumb :workgroup_aggregation_settings do |workgroup|
  link I18n.t('workgroups.edit_aggregate.title')
  parent workgroup
end

crumb :workgroup_edit_controls do |workgroup|
  link I18n.t('workgroups.edit_controls.title')
  parent workgroup
end

crumb :workgroup_hole_sentinel_settings do |workgroup|
  link I18n.t('workgroups.edit_hole_sentinel.title')
  parent workgroup
end


crumb :api_keys do |workbench|
  link I18n.t('api_keys.index.title'), workbench_api_keys_path(workbench)
  parent :workbench, workbench
end

crumb :notification_rules do |workbench|
  link I18n.t('notification_rules.index.title'), workbench_notification_rules_path(workbench)
  parent :workbench, workbench
end

crumb :notification_rule do |notification_rule|
  link notification_rule.name
  parent :notification_rules, notification_rule.workbench
end

# crumb :compliance_controls do|compliance_control_sets|
#   link
#   parent :compliance_control_sets, compliance_control_sets
# end

# crumb :project do |project|
#   link project.name, project_path(project)
#   parent :projects
# end

# crumb :project_issues do |project|
#   link "Issues", project_issues_path(project)
#   parent :project, project
# end

# crumb :issue do |issue|
#   link issue.title, issue_path(issue)
#   parent :project_issues, issue.project
# end

# If you want to split your breadcrumbs configuration over multiple files, you
# can create a folder named `config/breadcrumbs` and put your configuration
# files there. All *.rb files (e.g. `frontend.rb` or `products.rb`) in that
# folder are loaded and reloaded automatically when you change them, just like
# this file (`config/breadcrumbs.rb`).
