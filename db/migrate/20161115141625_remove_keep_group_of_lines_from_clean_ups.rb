class RemoveKeepGroupOfLinesFromCleanUps < ActiveRecord::Migration[4.2]
  def change
    remove_column :clean_ups, :keep_group_of_lines, :boolean
  end
end
