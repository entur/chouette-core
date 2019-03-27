class DropTableJourneyPatternSections < ActiveRecord::Migration[4.2]
  def change
    drop_table :journey_pattern_sections
  end
end
