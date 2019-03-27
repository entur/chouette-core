class AddOrganisationToApiKeys < ActiveRecord::Migration[4.2]
  def change
    add_reference :api_keys, :organisation, index: true, foreign_key: true
  end
end
