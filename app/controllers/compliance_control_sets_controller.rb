class ComplianceControlSetsController < InheritedResources::Base
  defaults resource_class: ComplianceControlSet
  include RansackDateFilter
  before_action only: [:index] { set_date_time_params("updated_at", DateTime) }
  respond_to :html

  def index
    index! do |format|
      scope = self.ransack_period_range(scope: @compliance_control_sets, error_message: t('imports.filters.error_period_filter'), query: :where_updated_at_between)
      @q_for_form = scope.ransack(params[:q])
      format.html {
        @compliance_control_sets = decorate_compliance_control_sets(@q_for_form.result.paginate(page: params[:page], per_page: 30))
      }
    end
  end

  def show
    show!(&method(:implement_show))
  end


  def clone
    ComplianceControlSetCloner.new.copy(params[:id], current_organisation.id)
    flash[:notice] = I18n.t("compliance_control_sets.errors.operation_in_progress")
    redirect_to(compliance_control_sets_path)
  end

  protected

  def begin_of_association_chain
    current_organisation
  end

  private

  def decorate_compliance_control_sets(compliance_control_sets)
    ModelDecorator.decorate(
      compliance_control_sets,
      with: ComplianceControlSetDecorator
    )
  end

  def decorate_compliance_controls(compliance_controls)
    ModelDecorator.decorate(
      compliance_controls,
      with: ComplianceControlDecorator,
    )
  end

  def compliance_control_set_params
    params.require(:compliance_control_set).permit(:name, :id)
  end

  def implement_show format
    format.html(&method(:implement_show_for_html))
  end

  def implement_show_for_html _mime_response
    @q_controls_form        = @compliance_control_set.compliance_controls.ransack(params[:q])
    @compliance_control_set = @compliance_control_set.decorate
    @compliance_controls    =
      decorate_compliance_controls( @q_controls_form.result)
      .group_by(&:compliance_control_block)
    @direct_compliance_controls = @compliance_controls.delete nil
  end
end
