class AddObjectIdFormatToWorkbenches < ActiveRecord::Migration[4.2]
  def change
    add_column :workbenches, :objectid_format, :string unless column_exists? :workbenches, :objectid_format
  end
end
