class AddTransportSubmodeToLines < ActiveRecord::Migration[4.2]
  def change
    add_column :lines, :transport_submode, :string
  end
end
