class ChangeForeignKeysToBigint < ActiveRecord::Migration[4.2]
  def change
    change_column :stop_area_referential_syncs, :stop_area_referential_id, :bigint
    change_column :stop_area_referential_sync_messages, :stop_area_referential_sync_id, :bigint
    change_column :stop_area_referential_memberships, :organisation_id, :bigint
    change_column :stop_area_referential_memberships, :stop_area_referential_id, :bigint
    change_column :line_referential_memberships, :organisation_id, :bigint
    change_column :line_referential_memberships, :line_referential_id, :bigint
    change_column :line_referential_sync_messages, :line_referential_sync_id, :bigint
    change_column :line_referential_syncs, :line_referential_id, :bigint
    change_column :referential_metadata, :referential_id, :bigint
    change_column :referential_metadata, :line_ids, :bigint, array: true
    change_column :referential_metadata, :referential_source_id, :bigint
    change_column :workbenches, :organisation_id, :bigint
    change_column :workbenches, :line_referential_id, :bigint
    change_column :workbenches, :stop_area_referential_id, :bigint
    change_column :api_keys, :referential_id, :bigint
    change_column :calendars, :organisation_id, :bigint
    change_column :clean_up_results, :clean_up_id, :bigint
    change_column :clean_ups, :referential_id, :bigint
    change_column :companies, :line_referential_id, :bigint
    change_column :group_of_lines, :line_referential_id, :bigint
    change_column :import_messages, :import_id, :bigint
    change_column :import_messages, :resource_id, :bigint
    change_column :import_resources, :import_id, :bigint
    change_column :imports, :workbench_id, :bigint
    change_column :imports, :referential_id, :bigint
    change_column :lines, :line_referential_id, :bigint
    change_column :lines, :secondary_company_ids, :bigint, array: true
    change_column :networks, :line_referential_id, :bigint
    change_column :referential_clonings, :source_referential_id, :bigint
    change_column :referential_clonings, :target_referential_id, :bigint
    change_column :referentials, :line_referential_id, :bigint
    change_column :referentials, :stop_area_referential_id, :bigint
    change_column :referentials, :workbench_id, :bigint
    change_column :referentials, :created_from_id, :bigint
    change_column :routing_constraint_zones, :line_id, :bigint
    change_column :stop_areas, :stop_area_referential_id, :bigint
    change_column :taggings, :tag_id, :bigint
    change_column :taggings, :taggable_id, :bigint
    change_column :taggings, :tagger_id, :bigint
    change_column :time_tables, :calendar_id, :bigint
    change_column :users, :organisation_id, :bigint
    change_column :users, :invited_by_id, :bigint
  end
end
