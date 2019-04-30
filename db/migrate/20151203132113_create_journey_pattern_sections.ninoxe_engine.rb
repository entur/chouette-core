# This migration comes from ninoxe_engine (originally 20151203131606)
class CreateJourneyPatternSections < ActiveRecord::Migration[4.2]
  def change
    create_table :journey_pattern_sections do |t|
      t.references :journey_pattern, null: false, index: true, limit: 8
      t.references :route_section, null: false, index: true, limit: 8
      t.integer :rank, null: false
      t.timestamps
    end
    add_foreign_key :journey_pattern_sections, :journey_patterns, on_delete: :cascade
    add_foreign_key :journey_pattern_sections, :route_sections, on_delete: :cascade

    add_index :journey_pattern_sections, [:journey_pattern_id, :route_section_id, :rank],
              unique: true, name: 'index_jps_on_journey_pattern_id_and_route_section_id_and_rank'
  end
end
