class NormalizeWorkbenchPrefixes < ActiveRecord::Migration[4.2]
  def up
    Workbench.find_each do |w|
      w.update prefix: w.prefix
    end
  end
end
