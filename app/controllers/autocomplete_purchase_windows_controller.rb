class AutocompletePurchaseWindowsController < ChouetteController
  respond_to :json, :only => [:index]

  requires_feature :purchase_windows

  include ReferentialSupport

  protected
  def collection
    @purchase_windows = referential.purchase_windows.ransack(params[:q]).result.paginate(page: params[:page])
  end
end
