class DropTableRouteSections < ActiveRecord::Migration[4.2]
  def change
    drop_table :route_sections
  end
end
