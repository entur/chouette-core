class AddLineReferntialToNetworks < ActiveRecord::Migration[4.2]
  def change
    add_reference :networks, :line_referential, index: true
  end
end
