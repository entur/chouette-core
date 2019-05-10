class AutocompleteTimeTablesController < ChouetteController
  respond_to :json, :only => [:index]

  include ReferentialSupport

  protected

  def select_time_tables
    scope = params[:source_id] ? referential.time_tables.where("time_tables.id != ?", params[:source_id]) : referential.time_tables
    if params[:route_id]
      scope = scope.joins(vehicle_journeys: :route).where( "routes.id IN (#{params[:route_id]})")
    end
    attrs = %w[id comment objectid color int_day_types].map {|a| "time_tables.#{a}"}
    scope.select("#{attrs.join(',')}").distinct
  end

  def split_params! search
    params[:q][search] = params[:q][search].split(" ") if params[:q] && params[:q][search]
  end

  def collection
    split_params! :unaccented_comment_or_objectid_cont_any
    @time_tables = select_time_tables.ransack(params[:q]).result.paginate(page: params[:page]).select('lower(time_tables.comment) AS lower_comment').order("lower_comment ASC")
  end
end
