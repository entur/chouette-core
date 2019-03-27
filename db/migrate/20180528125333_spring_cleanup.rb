class SpringCleanup < ActiveRecord::Migration[4.2]
  def change
    [:journey_frequencies, :timebands].each do |t|
      drop_table t
    end
  end
end
