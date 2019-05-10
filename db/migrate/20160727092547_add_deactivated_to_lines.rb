class AddDeactivatedToLines < ActiveRecord::Migration[4.2]
  def change
    add_column :lines, :deactivated, :boolean, default: false
  end
end
