class AddCustomFieldValuesToJourneyPatterns < ActiveRecord::Migration[4.2]
  def change
    add_column :journey_patterns, :custom_field_values, :jsonb
  end
end
