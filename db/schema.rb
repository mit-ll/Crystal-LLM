# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2024_01_17_150513) do
  create_table "chains", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "user_id"
    t.integer "chain_order"
  end

  create_table "jobs", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "user_id"
    t.integer "question_id"
    t.integer "template_id"
    t.integer "model_id"
    t.boolean "is_running"
    t.boolean "is_done"
    t.datetime "start_time"
    t.datetime "run_time"
    t.datetime "created_at"
  end

  create_table "models", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "tool_id"
    t.string "modelname", limit: 200
    t.string "model_version", limit: 40
    t.string "group_name", limit: 40
    t.string "host_name", limit: 80
    t.string "host_port", limit: 10
    t.boolean "has_curl"
    t.boolean "has_singularity"
    t.boolean "has_docker"
    t.boolean "is_code"
    t.boolean "is_up"
  end

  create_table "questions", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "user_id"
    t.integer "chain_id"
    t.integer "template_id"
    t.string "query_text", limit: 4095
    t.integer "chain_order"
  end

  create_table "responses", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "user_id"
    t.integer "question_id"
    t.integer "tool_id"
    t.integer "model_id"
    t.integer "chain_id"
    t.integer "chain_order"
    t.datetime "runtime"
    t.datetime "created_at"
    t.text "response_text"
  end

  create_table "templates", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "user_id"
    t.string "template_text", limit: 4095
  end

  create_table "tools", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "tool_name", limit: 80
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "user_name", limit: 80
    t.boolean "is_admin"
  end

end
