class AddStopAreaReferentialToWorkbenches < ActiveRecord::Migration[4.2]
  def change
    add_reference :workbenches, :stop_area_referential, index: true
  end
end
