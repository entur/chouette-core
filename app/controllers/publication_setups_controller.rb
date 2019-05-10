class PublicationSetupsController < ChouetteController
  include PolicyChecker

  requires_feature :manage_publications

  defaults :resource_class => PublicationSetup
  belongs_to :workgroup

  respond_to :html

  def index
    index! do |format|
      format.html {
        @publication_setups = decorate_publication_setups(@publication_setups)
      }
    end
  end

  def show
    show! do |format|
      format.html {
        @publications = PublicationDecorator.decorate(
          @publication_setup.publications.order('created_at DESC').paginate(page: params[:page]),
          context: {
            workgroup: @workgroup,
            publication_setup: @publication_setup
          }
        )
      }
    end
  end

  def publication_setup_params
    publication_setup_params = params.require(:publication_setup)
    permitted_keys = [:name, :export_type, :export_options, :enabled, :workgroup_id]
    publication_setup_params[:workgroup_id] = parent.id
    export_class = publication_setup_params[:export_type] && publication_setup_params[:export_type].safe_constantize
    if export_class
      permitted_keys << { export_options: export_class.options.map {|k, v| v[:name].presence || k } }
    end
    permitted_destinations_attributes = [:id, :name, :type, :_destroy, :secret_file, :publication_setup_id, :publication_api_id]
    permitted_destinations_attributes += Destination.descendants.map{ |t| t.options.keys }.uniq
    permitted_keys << { destinations_attributes: permitted_destinations_attributes }
    publication_setup_params.permit(permitted_keys)
  end

  def resource
    super.decorate(context: { workgroup: parent })
  end

  def collection
    @q = end_of_association_chain.ransack(params[:q])
    scope = @q.result(distinct: true)
    scope = scope.order(sort_column + ' ' + sort_direction)
    @publication_setups = scope.paginate(page: params[:page])
  end

  def sort_column
    (PublicationSetup.column_names).include?(params[:sort]) ? params[:sort] : 'name'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end

  def decorate_publication_setups publication_setups
    PublicationSetupDecorator.decorate(
      publication_setups,
      context: {
        workgroup: parent
      }
    )
  end
end
