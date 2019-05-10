class AddInfosOnDestinationReports < ActiveRecord::Migration[4.2]
  def change
    add_column :destination_reports, :error_message, :string
    add_column :destination_reports, :error_backtrace, :text
  end
end
