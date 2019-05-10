class StifDefineCustomViewForOrganisations < ActiveRecord::Migration[4.2]
  def change
    Organisation.update_all custom_view: "stif"
  end
end
