class CleanUpsController < ChouetteController
  include ReferentialSupport

  belongs_to :referential

  defaults :resource_class => CleanUp

  def new
    build_resource
    @clean_up.begin_date = @referential.metadatas_period&.min
    @clean_up.end_date = @referential.metadatas_period&.max
  end

  def create
    create! do |success, _failure|
      success.html do
        redirect_to @referential
      end
    end
  end

  def get_methods
    method_params.keys.select do |k|
      method_params[k] == 'true'
    end
  end

  def method_params
     params.require(:method_types).permit(
       :destroy_journey_patterns_without_vehicle_journey,
       :destroy_vehicle_journeys_without_purchase_window,
       :destroy_routes_without_journey_pattern,
       :destroy_unassociated_timetables,
       :destroy_unassociated_purchase_windows
     )
  end

  def clean_up_params
    params.require(:clean_up).permit(:date_type, :begin_date, :end_date).update(method_types: get_methods)
  end

  def begin_of_association_chain
    nil
  end
end
