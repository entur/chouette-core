class AddOutputToWorkbenches < ActiveRecord::Migration[4.2]
  def change
    add_column :workbenches, :output_id, :bigint, index: true
  end
end
