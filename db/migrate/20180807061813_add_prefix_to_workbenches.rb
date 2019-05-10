class AddPrefixToWorkbenches < ActiveRecord::Migration[4.2]
  def change
    add_column :workbenches, :prefix, :string
  end
end
