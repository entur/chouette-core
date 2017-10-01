class ReferentialsController < BreadcrumbController
  defaults :resource_class => Referential
  include PolicyChecker

  respond_to :html
  respond_to :json, :only => :show
  respond_to :js, :only => :show

  def new
    new! do
      build_referenial
    end
  end

  def create
    create! do |format|
      build_referenial

      if !!@referential.created_from_id
        format.html { redirect_to workbench_path(@referential.workbench) }
      else
        build_breadcrumb :new
      end
    end
  end

  def show
    resource.switch
    show! do |format|
      @referential = @referential.decorate(context: { current_workbench_id: params[:current_workbench_id] } )
      @reflines = lines_collection.paginate(page: params[:page], per_page: 10)
      @reflines = ModelDecorator.decorate(
        @reflines,
        with: ReferentialLineDecorator,
        context: {
          referential: referential,
          current_organisation: current_organisation
        }
      )

      format.json {
        render :json => { :lines_count => resource.lines.count,
               :networks_count => resource.networks.count,
               :vehicle_journeys_count => resource.vehicle_journeys.count + resource.vehicle_journey_frequencies.count,
               :time_tables_count => resource.time_tables.count,
               :referential_id => resource.id}
      }
      format.html { build_breadcrumb :show}
    end
  end

  def edit
    edit! do
      if @referential.in_workbench?
        @referential.init_metadatas default_date_range: Range.new(Date.today, Date.today.advance(months: 1))
      end
    end
  end

  def destroy
    workbench = referential.workbench_id

    referential.destroy!
    redirect_to workbench_path(workbench), notice: t('notice.referential.deleted')
  end

  def archive
    referential.archive!
    redirect_to workbench_path(referential.workbench_id), notice: t('notice.referential.archived')
  end
  def unarchive
    if referential.unarchive!
      flash[:notice] = t('notice.referential.unarchived')
    else
      flash[:alert] = t('notice.referential.unarchived_failed')
    end

    redirect_to workbench_path(referential.workbench_id)
  end

  protected

  alias_method :referential, :resource
  alias_method :current_referential, :referential
  helper_method :current_referential

  def resource
    @referential ||= current_organisation.find_referential(params[:id])
  end

  def collection
    @referentials ||= current_organisation.referentials.order(:name)
  end

  def lines_collection
    @q = resource.lines.includes(:company, :network).search(params[:q])

    if sort_column && sort_direction
      @reflines ||=
        begin
          reflines = @q.result(distinct: true).order(sort_column + ' ' + sort_direction)
          reflines = reflines.paginate(page: params[:page], per_page: 10)
          reflines
        end
    else
      @reflines ||=
        begin
          reflines = @q.result(distinct: true).order(:name)
          reflines = reflines.paginate(page: params[:page], per_page: 10)
          reflines
        end
    end
  end

  def build_resource
    super.tap do |referential|
      referential.user_id = current_user.id
      referential.user_name = current_user.name
    end
  end

  def create_resource(referential)
    referential.organisation = current_organisation
    referential.ready = true
    super
  end

  def build_referenial
    if params[:from]
      source_referential = Referential.find(params[:from])

      overrides = {}
      overrides[:workbench] = Workbench.find params[:current_workbench_id] if params[:current_workbench_id]

      @referential = Referential.new_from(source_referential, overrides)
    end

    @referential.data_format = current_organisation.data_format
    @referential.workbench_id ||= params[:workbench_id]

    if @referential.in_workbench?
      @referential.init_metadatas default_date_range: Range.new(Date.today, Date.today.advance(months: 1))
    end
  end

  private
  def sort_column
    sortable_columns = Chouette::Line.column_names + ['networks.name', 'companies.name']
    params[:sort] if sortable_columns.include?(params[:sort])
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ?  params[:direction] : 'asc'
  end

  def referential_params
    params.require(:referential).permit(
      :id,
      :name,
      :organisation_id,
      :data_format,
      :archived_at,
      :created_from_id,
      :workbench_id,
      metadatas_attributes: [:id, :first_period_begin, :first_period_end, periods_attributes: [:begin, :end, :id, :_destroy], :lines => []]
    )
  end

end
