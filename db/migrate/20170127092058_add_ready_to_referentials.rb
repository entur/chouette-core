class AddReadyToReferentials < ActiveRecord::Migration[4.2]
  def change
    add_column :referentials, :ready, :boolean, default: false
  end
end
