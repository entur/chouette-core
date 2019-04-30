class AddRegistrationNumberFormatToStopAreaReferentials < ActiveRecord::Migration[4.2]
  def change
    add_column :stop_area_referentials, :registration_number_format, :string
  end
end
