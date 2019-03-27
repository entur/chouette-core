class AddCostsToRoutes < ActiveRecord::Migration[4.2]
  def change
    add_column :routes, :costs, :json
  end
end
