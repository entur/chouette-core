class AddOfferWorkbenchToReferentials < ActiveRecord::Migration[4.2]
  def change
    add_reference :referentials, :offer_workbench
  end
end
