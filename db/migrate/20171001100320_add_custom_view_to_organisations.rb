class AddCustomViewToOrganisations < ActiveRecord::Migration[4.2]
  def change
    add_column :organisations, :custom_view, :string
  end
end
