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

  create_table "artifacts", force: true do |t|
    t.integer  "job_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "asset_file_name"
    t.string   "asset_content_type"
    t.integer  "asset_file_size"
    t.datetime "asset_updated_at"
  end

  add_index "artifacts", ["job_id"], name: "index_artifacts_on_job_id"

  create_table "assets", force: true do |t|
    t.integer  "project_id"
    t.string   "name"
    t.string   "file"
    t.string   "version"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "asset_file_name"
    t.string   "asset_content_type"
    t.integer  "asset_file_size"
    t.datetime "asset_updated_at"
  end

  add_index "assets", ["project_id"], name: "index_assets_on_project_id"

  create_table "batch_assets", force: true do |t|
    t.integer  "batch_id"
    t.integer  "asset_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "batch_assets", ["asset_id"], name: "index_batch_assets_on_asset_id"
  add_index "batch_assets", ["batch_id"], name: "index_batch_assets_on_batch_id"

  create_table "batches", force: true do |t|
    t.string   "name",                        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id",                  null: false
    t.string   "version",                     null: false
    t.string   "build_file_name"
    t.string   "build_content_type"
    t.integer  "build_file_size"
    t.datetime "build_updated_at"
    t.binary   "target_information"
    t.integer  "number_of_automatic_retries"
    t.binary   "execution_variables"
  end

  add_index "batches", ["project_id"], name: "index_batches_on_project_id"

  create_table "curated_queues", force: true do |t|
    t.string   "name"
    t.binary   "queues"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority"

  create_table "fields", force: true do |t|
    t.string   "name"
    t.string   "field_type"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "default_value"
  end

  add_index "fields", ["owner_id", "owner_type"], name: "index_fields_on_owner_id_and_owner_type"

  create_table "hive_queues", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "hive_queues_workers", id: false, force: true do |t|
    t.integer "worker_id",     null: false
    t.integer "hive_queue_id", null: false
  end

  add_index "hive_queues_workers", ["hive_queue_id", "worker_id"], name: "index_hive_queues_workers_on_hive_queue_id_and_worker_id", unique: true
  add_index "hive_queues_workers", ["worker_id"], name: "index_hive_queues_workers_on_worker_id"

  create_table "job_groups", force: true do |t|
    t.integer  "batch_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.binary   "execution_variables"
    t.integer  "hive_queue_id"
  end

  add_index "job_groups", ["batch_id"], name: "index_job_groups_on_batch_id"
  add_index "job_groups", ["hive_queue_id"], name: "index_job_groups_on_hive_queue_id"

  create_table "jobs", force: true do |t|
    t.string   "job_name",                        null: false
    t.string   "state",                           null: false
    t.integer  "queued_count"
    t.integer  "running_count"
    t.integer  "passed_count"
    t.integer  "failed_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "errored_count"
    t.integer  "retry_count",         default: 0, null: false
    t.integer  "device_id"
    t.integer  "job_group_id"
    t.integer  "original_job_id"
    t.binary   "execution_variables"
    t.datetime "reserved_at"
    t.binary   "reservation_details"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "result"
    t.integer  "exit_value"
    t.text     "message"
    t.datetime "script_start_time"
    t.datetime "script_end_time"
  end

  add_index "jobs", ["device_id"], name: "index_jobs_on_device_id"
  add_index "jobs", ["job_group_id"], name: "index_jobs_on_job_group_id"
  add_index "jobs", ["original_job_id"], name: "index_jobs_on_original_job_id"
  add_index "jobs", ["state", "job_group_id"], name: "index_jobs_on_state_and_job_group_id"

  create_table "projects", force: true do |t|
    t.string   "name",                              null: false
    t.string   "repository",                        null: false
    t.string   "execution_directory", default: ".", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "script_id",                         null: false
    t.string   "builder_name"
    t.binary   "builder_options"
    t.datetime "deleted_at"
    t.binary   "execution_variables"
    t.string   "branch"
  end

  add_index "projects", ["deleted_at"], name: "index_projects_on_deleted_at"
  add_index "projects", ["script_id"], name: "index_projects_on_script_id"

  create_table "scripts", force: true do |t|
    t.string   "name",                          null: false
    t.text     "template",                      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "target_id"
    t.boolean  "install_build", default: false
  end

  create_table "targets", force: true do |t|
    t.string   "name"
    t.string   "icon"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "requires_build", default: false
  end

  create_table "test_cases", force: true do |t|
    t.string   "name"
    t.string   "urn"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "test_cases", ["project_id"], name: "index_test_cases_on_project_id"

  create_table "test_results", force: true do |t|
    t.string   "status"
    t.text     "message"
    t.integer  "test_case_id"
    t.integer  "job_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "test_results", ["job_id"], name: "index_test_results_on_job_id"
  add_index "test_results", ["test_case_id"], name: "index_test_results_on_test_case_id"

  create_table "users", force: true do |t|
    t.string "name"
    t.string "email"
    t.string "provider"
    t.string "uid"
  end

  create_table "workers", force: true do |t|
    t.integer  "hive_id"
    t.integer  "pid"
    t.integer  "device_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "workers", ["hive_id", "pid", "device_id"], name: "index_hive_id_pid_on_workers"

end
