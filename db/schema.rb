# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170315110114) do

  create_table "artifacts", force: :cascade do |t|
    t.integer  "job_id",             limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "asset_file_name",    limit: 255
    t.string   "asset_content_type", limit: 255
    t.integer  "asset_file_size",    limit: 4
    t.datetime "asset_updated_at"
  end

  add_index "artifacts", ["job_id"], name: "index_artifacts_on_job_id", using: :btree

  create_table "assets", force: :cascade do |t|
    t.integer  "project_id",         limit: 4
    t.string   "name",               limit: 255
    t.string   "file",               limit: 255
    t.string   "version",            limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "asset_file_name",    limit: 255
    t.string   "asset_content_type", limit: 255
    t.integer  "asset_file_size",    limit: 4
    t.datetime "asset_updated_at"
  end

  add_index "assets", ["project_id"], name: "index_assets_on_project_id", using: :btree

  create_table "batch_assets", force: :cascade do |t|
    t.integer  "batch_id",   limit: 4
    t.integer  "asset_id",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "batch_assets", ["asset_id"], name: "index_batch_assets_on_asset_id", using: :btree
  add_index "batch_assets", ["batch_id"], name: "index_batch_assets_on_batch_id", using: :btree

  create_table "batches", force: :cascade do |t|
    t.string   "name",                        limit: 255,   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id",                  limit: 4,     null: false
    t.string   "version",                     limit: 255,   null: false
    t.string   "build_file_name",             limit: 255
    t.string   "build_content_type",          limit: 255
    t.integer  "build_file_size",             limit: 4
    t.datetime "build_updated_at"
    t.binary   "target_information",          limit: 65535
    t.integer  "number_of_automatic_retries", limit: 4
    t.binary   "execution_variables",         limit: 65535
  end

  add_index "batches", ["project_id"], name: "index_batches_on_project_id", using: :btree

  create_table "curated_queues", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.binary   "queues",     limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0, null: false
    t.integer  "attempts",   limit: 4,     default: 0, null: false
    t.text     "handler",    limit: 65535,             null: false
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "fields", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.string   "field_type",    limit: 255
    t.integer  "owner_id",      limit: 4
    t.string   "owner_type",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "default_value", limit: 255
  end

  add_index "fields", ["owner_id", "owner_type"], name: "index_fields_on_owner_id_and_owner_type", using: :btree

  create_table "hive_queues", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "hive_queues_workers", id: false, force: :cascade do |t|
    t.integer "worker_id",     limit: 4, null: false
    t.integer "hive_queue_id", limit: 4, null: false
  end

  add_index "hive_queues_workers", ["hive_queue_id", "worker_id"], name: "index_hive_queues_workers_on_hive_queue_id_and_worker_id", unique: true, using: :btree
  add_index "hive_queues_workers", ["worker_id"], name: "index_hive_queues_workers_on_worker_id", using: :btree

  create_table "job_groups", force: :cascade do |t|
    t.integer  "batch_id",            limit: 4
    t.string   "name",                limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.binary   "execution_variables", limit: 65535
    t.integer  "hive_queue_id",       limit: 4
  end

  add_index "job_groups", ["batch_id"], name: "index_job_groups_on_batch_id", using: :btree
  add_index "job_groups", ["hive_queue_id"], name: "index_job_groups_on_hive_queue_id", using: :btree

  create_table "jobs", force: :cascade do |t|
    t.string   "job_name",            limit: 255,               null: false
    t.string   "state",               limit: 255,               null: false
    t.integer  "queued_count",        limit: 4
    t.integer  "running_count",       limit: 4
    t.integer  "passed_count",        limit: 4
    t.integer  "failed_count",        limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "errored_count",       limit: 4
    t.integer  "retry_count",         limit: 4,     default: 0, null: false
    t.integer  "device_id",           limit: 4
    t.integer  "job_group_id",        limit: 4
    t.integer  "original_job_id",     limit: 4
    t.binary   "execution_variables", limit: 65535
    t.datetime "reserved_at"
    t.binary   "reservation_details", limit: 65535
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "result",              limit: 255
    t.integer  "exit_value",          limit: 4
    t.text     "message",             limit: 65535
    t.datetime "script_start_time"
    t.datetime "script_end_time"
  end

  add_index "jobs", ["device_id"], name: "index_jobs_on_device_id", using: :btree
  add_index "jobs", ["job_group_id"], name: "index_jobs_on_job_group_id", using: :btree
  add_index "jobs", ["original_job_id"], name: "index_jobs_on_original_job_id", using: :btree
  add_index "jobs", ["state", "job_group_id"], name: "index_jobs_on_state_and_job_group_id", using: :btree

  create_table "projects", force: :cascade do |t|
    t.string   "name",                limit: 255,                 null: false
    t.string   "repository",          limit: 255,                 null: false
    t.string   "execution_directory", limit: 255,   default: ".", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "script_id",           limit: 4,                   null: false
    t.string   "builder_name",        limit: 255
    t.binary   "builder_options",     limit: 65535
    t.datetime "deleted_at"
    t.binary   "execution_variables", limit: 65535
    t.string   "branch",              limit: 255
  end

  add_index "projects", ["deleted_at"], name: "index_projects_on_deleted_at", using: :btree
  add_index "projects", ["script_id"], name: "index_projects_on_script_id", using: :btree

  create_table "scripts", force: :cascade do |t|
    t.string   "name",          limit: 255,                   null: false
    t.text     "template",      limit: 65535,                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "target_id",     limit: 4
    t.boolean  "install_build",               default: false
  end

  create_table "targets", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.string   "icon",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "requires_build",             default: false
  end

  create_table "test_cases", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "urn",        limit: 255
    t.integer  "project_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "test_cases", ["project_id"], name: "index_test_cases_on_project_id", using: :btree

  create_table "test_results", force: :cascade do |t|
    t.string   "status",       limit: 255
    t.text     "message",      limit: 65535
    t.integer  "test_case_id", limit: 4
    t.integer  "job_id",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "test_results", ["job_id"], name: "index_test_results_on_job_id", using: :btree
  add_index "test_results", ["test_case_id"], name: "index_test_results_on_test_case_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string "name",     limit: 255
    t.string "email",    limit: 255
    t.string "provider", limit: 255
    t.string "uid",      limit: 255
  end

  create_table "workers", force: :cascade do |t|
    t.integer  "hive_id",    limit: 4
    t.integer  "pid",        limit: 4
    t.integer  "device_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "workers", ["hive_id", "pid", "device_id"], name: "index_hive_id_pid_on_workers", using: :btree

end
