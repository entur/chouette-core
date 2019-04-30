class AccessPointsController < ChouetteController
  include ReferentialSupport
  defaults :resource_class => Chouette::AccessPoint

  belongs_to :referential do
    belongs_to :stop_area, :parent_class => Chouette::StopArea, :optional => true, :polymorphic => true
  end

  respond_to :html, :kml, :xml, :json
  include PolicyChecker

  def index
    request.format.kml? ? @per_page = nil : @per_page = 12

    index! do |format|
      format.html {
        if collection.out_of_bounds?
          redirect_to params.merge(:page => 1)
        end
      }
    end
  end

  def show
    @generic_access_links = @access_point.generic_access_link_matrix
    @detail_access_links = @access_point.detail_access_link_matrix
    show! do |format|
      unless access_point.position or params[:default]
        format.kml {
          render :nothing => true, :status => :not_found
        }

      end
    end
  end


  def edit
    access_point.position ||= access_point.default_position
    edit!
  end


  protected

  alias_method :access_point, :resource

  def collection
    @q = parent.access_points.ransack(params[:q])
    @access_points ||=
      begin
        access_points = @q.result(:distinct => true).order(:name)
        access_points = access_points.paginate(:page => params[:page]) if @per_page.present?
        access_points
      end
  end

  private

  def access_point_params
    params.require(:access_point).permit( :objectid, :object_version, :name, :comment, :longitude, :latitude, :long_lat_type, :country_code, :street_name, :zip_code, :city_name, :openning_time, :closing_time, :access_type, :access_point_type, :mobility_restricted_suitability, :stairs_availability, :lift_availability, :stop_area_id, :coordinates )
  end

end
