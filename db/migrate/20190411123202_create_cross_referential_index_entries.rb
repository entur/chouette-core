class CreateCrossReferentialIndexEntries < ActiveRecord::Migration[4.2]
  def change
    on_public_schema_only do
      create_table :cross_referential_index_entries do |t|
        t.string :parent_type
        t.integer :parent_id, limit: 8
        t.string :target_type
        t.integer :target_id, limit: 8
        t.string :relation_name
        t.string :target_referential_slug

        t.timestamps null: false
      end

      add_index :cross_referential_index_entries, :relation_name
      add_index :cross_referential_index_entries, [:relation_name, :parent_type, :parent_id, :target_referential_slug], name: :cross_referential_index_entries_parent
      add_index :cross_referential_index_entries, [:relation_name, :target_type, :target_id, :target_referential_slug], name: :cross_referential_index_entries_target
    end
  end
end
