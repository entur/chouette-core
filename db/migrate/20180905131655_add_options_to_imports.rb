class AddOptionsToImports < ActiveRecord::Migration[4.2]
  def change
    # Avoid error in the case of issue #8255
    return if ActiveRecord::Base.connection.column_exists?(:imports, :options)

    add_column :imports, :options, :hstore
  end
end
