class AddStopAreaReferentialToReferential < ActiveRecord::Migration[4.2]
  def change
    add_reference :referentials, :stop_area_referential
  end
end
