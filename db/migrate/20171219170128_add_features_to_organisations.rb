class AddFeaturesToOrganisations < ActiveRecord::Migration[4.2]
  def change
    add_column :organisations, :features, :string, array: true, default: []
  end
end
