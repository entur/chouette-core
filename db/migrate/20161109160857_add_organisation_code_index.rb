class AddOrganisationCodeIndex < ActiveRecord::Migration[4.2]
  def change
    add_index :organisations, :code, unique: true
  end
end
