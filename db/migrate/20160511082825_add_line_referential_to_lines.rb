class AddLineReferentialToLines < ActiveRecord::Migration[4.2]
  def change
    add_reference :lines, :line_referential, index: true
  end
end
