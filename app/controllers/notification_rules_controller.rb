class NotificationRulesController < ChouetteController
  include PolicyChecker
  include RansackDateFilter
  before_action(only: [:index]) { set_date_time_params("period", Date, prefix: :notification_rule) }

  defaults resource_class: NotificationRule
  belongs_to :workbench
  before_action :update_period_params, only: [:create, :update]

  def index
    index! do |format|
      scope = ransack_period_range(scope: @notification_rules, error_message:  t('referentials.errors.validity_period'), query: :in_periode, prefix: :notification_rule)
      @q = scope.ransack(params[:q])

      format.html {
        @notification_rules = NotificationRuleDecorator.decorate(
          @q.result(distinct: true).paginate(page: params[:page]),
            context: {
              workbench: @workbench
            }
        )
      }
    end
  end

  def show
    show! do
      @notification_rule = @notification_rule.decorate(context: { workbench: @workbench })
    end
  end

  private
  def notification_rule_params
    params.require(:notification_rule).permit(
      :id,
      :notification_type,
      :period,
      :line_id
    )
  end

  def create_resource(object)
    object.period = params[:period]
    super
  end

  def update_resource(object, attributes)
    object.period = params[:period]
    super
  end

  def update_period_params
    start_date = Date.new(
      params['period']['min(1i)'].to_i,
      params['period']['min(2i)'].to_i,
      params['period']['min(3i)'].to_i,
    )

    end_date = Date.new(
      params['period']['max(1i)'].to_i,
      params['period']['max(2i)'].to_i,
      params['period']['max(3i)'].to_i,
    )
    params['period'] = Range.new(start_date, end_date)
  end
end
