class AddSsoAttributesToOrganisations < ActiveRecord::Migration[4.2]
  def change
    add_column :organisations, :sso_attributes, :hstore
  end
end
