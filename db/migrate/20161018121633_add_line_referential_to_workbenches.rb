class AddLineReferentialToWorkbenches < ActiveRecord::Migration[4.2]
  def change
    add_reference :workbenches, :line_referential, index: true
  end
end
