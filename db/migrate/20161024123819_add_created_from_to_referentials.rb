class AddCreatedFromToReferentials < ActiveRecord::Migration[4.2]
  def change
    add_reference :referentials, :created_from, index: true
  end
end
