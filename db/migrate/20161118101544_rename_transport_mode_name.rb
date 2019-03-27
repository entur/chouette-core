class RenameTransportModeName < ActiveRecord::Migration[4.2]
  def change
    rename_column :lines, :transport_mode_name, :transport_mode
  end
end
