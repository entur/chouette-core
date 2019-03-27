class AddRegistrationNumberIndexes < ActiveRecord::Migration[4.2]
  def change
    add_index :stop_areas, [:stop_area_referential_id, :registration_number], name: 'index_stop_areas_on_referential_id_and_registration_number'
    add_index :lines, [:line_referential_id, :registration_number], name: 'index_lines_on_referential_id_and_registration_number'
    add_index :companies, [:line_referential_id, :registration_number], name: 'index_companies_on_referential_id_and_registration_number'
  end
end
