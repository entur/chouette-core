class CleanUpsController < ChouetteController
  include ReferentialSupport

  belongs_to :referential

  defaults :resource_class => CleanUp

  def create
    create! do |success, _failure|
      success.html do
        redirect_to @referential
      end
    end
  end

  def get_data_cleanups
    data_cleanups_params.keys.select do |k|
      data_cleanups_params[k] == 'true'
    end
  end

  def data_cleanups_params
     params.require(:data_cleanups).permit(CleanUp.data_cleanups.values)
  end

  def clean_up_params
    params.require(:clean_up).permit(:date_type, :begin_date, :end_date).update(data_cleanups: get_data_cleanups)
  end

  def begin_of_association_chain
    nil
  end
end
