class AddCostsToJourneyPatterns < ActiveRecord::Migration[4.2]
  def change
    add_column :journey_patterns, :costs, :json
  end
end
