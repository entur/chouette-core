class AddObjectIdFormatToReferential < ActiveRecord::Migration[4.2]
  def change
    add_column :referentials, :objectid_format, :string unless column_exists? :referentials, :objectid_format
  end
end
