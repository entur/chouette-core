class CreateNewExports < ActiveRecord::Migration[4.2]
  def change
    create_table :exports do |t|
      t.string   "status"
      t.string   "current_step_id"
      t.float    "current_step_progress"
      t.integer  "workbench_id",          limit: 8
      t.integer  "referential_id",        limit: 8
      t.string   "name"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "file"
      t.datetime "started_at"
      t.datetime "ended_at"
      t.string   "token_upload"
      t.string   "type"
      t.integer  "parent_id",             limit: 8
      t.string   "parent_type"
      t.datetime "notified_parent_at"
      t.integer  "current_step",          default: 0
      t.integer  "total_steps",           default: 0
      t.string   "creator"
    end

    add_index "exports", ["referential_id"], name: "index_exports_on_referential_id", using: :btree
    add_index "exports", ["workbench_id"], name: "index_exports_on_workbench_id", using: :btree

    create_table "export_messages", id: :bigserial, force: :cascade do |t|
      t.string   "criticity"
      t.string   "message_key"
      t.hstore   "message_attributes"
      t.integer  "export_id",           limit: 8
      t.integer  "resource_id",         limit: 8
      t.datetime "created_at"
      t.datetime "updated_at"
      t.hstore   "resource_attributes"
    end

    add_index "export_messages", ["export_id"], name: "index_export_messages_on_export_id", using: :btree
    add_index "export_messages", ["resource_id"], name: "index_export_messages_on_resource_id", using: :btree

    create_table "export_resources", id: :bigserial, force: :cascade do |t|
      t.integer  "export_id",     limit: 8
      t.string   "status"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "resource_type"
      t.string   "reference"
      t.string   "name"
      t.hstore   "metrics"
    end

    add_index "export_resources", ["export_id"], name: "index_export_resources_on_export_id", using: :btree

  end
end
