class AddMethodTypesToCleanups < ActiveRecord::Migration
  def change
    add_column :clean_ups, :method_types, :string, array: true
  end
end
