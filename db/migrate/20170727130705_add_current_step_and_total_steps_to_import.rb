class AddCurrentStepAndTotalStepsToImport < ActiveRecord::Migration[4.2]
  def change
    add_column :imports, :current_step, :integer, default: 0
    add_column :imports, :total_steps, :integer, default: 0
  end
end
