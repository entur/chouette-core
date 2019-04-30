class CreateNewImports < ActiveRecord::Migration[4.2]
  def change
    create_table :imports do |t|
      t.string :status
      t.string :current_step_id
      t.float :current_step_progress
      t.references :workbench, index: true
      t.references :referential, index: true
      t.string :name

      t.timestamps
    end
  end
end
