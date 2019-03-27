class AddIndexResourceTypeOnCustomFields < ActiveRecord::Migration[4.2]
  def change
    add_index :custom_fields, :resource_type
  end
end
