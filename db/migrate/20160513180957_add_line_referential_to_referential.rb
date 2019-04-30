class AddLineReferentialToReferential < ActiveRecord::Migration[4.2]
  def change
    add_reference :referentials, :line_referential
  end
end
