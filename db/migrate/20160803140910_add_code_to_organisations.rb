class AddCodeToOrganisations < ActiveRecord::Migration[4.2]
  def change
    add_column :organisations, :code, :string
  end
end
