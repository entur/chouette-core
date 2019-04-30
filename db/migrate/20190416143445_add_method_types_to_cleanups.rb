class AddMethodTypesToCleanups < ActiveRecord::Migration[4.2]
  def change
    on_public_schema_only do
      add_column :clean_ups, :data_cleanups, :string, array: true
    end
  end
end
