class ChangeReferentialDateFormatToNetex < ActiveRecord::Migration[4.2]
  def up
    execute "UPDATE referentials SET data_format = 'netex'"
  end

  def down
    execute "UPDATE referentials SET data_format = 'neptune'"
  end
end
