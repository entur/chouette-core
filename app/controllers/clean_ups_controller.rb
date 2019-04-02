class CleanUpsController < ChouetteController
  include ReferentialSupport
  respond_to :html, :only => [:create]
  belongs_to :referential

  defaults :resource_class => CleanUp

  def create
    binding.pry
    # @clean_up = CleanUp.new(clean_up_params, methods: get_methods)
    # @clean_up.referential = @referential
    # if @clean_up.valid?
    #   @clean_up.save
    # else
    #   flash[:alert] = @clean_up.errors.full_messages.join("<br/>")
    # end
    # redirect_to referential_path(@referential)
  end

  def get_methods
   method_params.reduce([]) do |arr, met|
    met[1] == 'true' ? arr << met[0].to_sym : arr
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
    params.require(:clean_up).permit(:date_type, :begin_date, :end_date)
  end
end
