#
# If you changed the default Dashboard implementation (see Dashboard),
# this controller will use a custom partial like
# custom/dashboards/_dashboard.html.slim for Custom::Dashboard
#
class DashboardsController < ChouetteController
  respond_to :html, only: [:show]
  defaults :resource_class => Dashboard

  def show
    @dashboard = Dashboard.create self
    @workbenches = current_organisation.workbenches
  end

end
