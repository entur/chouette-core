class CleanFormerExports < ActiveRecord::Migration[4.2]
  def change
    drop_table :exports
  end
end
