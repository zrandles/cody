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

ActiveRecord::Schema.define(version: 20170912001904) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "pull_requests", id: :serial, force: :cascade do |t|
    t.string "status"
    t.string "number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "pending_reviews"
    t.string "completed_reviews"
    t.string "repository"
    t.integer "parent_pull_request_id"
    t.index ["parent_pull_request_id"], name: "index_pull_requests_on_parent_pull_request_id"
  end

  create_table "review_rules", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "type"
    t.string "file_match"
    t.string "reviewer"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "repository"
    t.string "short_code"
    t.decimal "frequency", default: "1.0"
  end

  create_table "reviewers", force: :cascade do |t|
    t.string "login"
    t.string "status"
    t.text "context"
    t.bigint "review_rule_id"
    t.bigint "pull_request_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pull_request_id"], name: "index_reviewers_on_pull_request_id"
    t.index ["review_rule_id"], name: "index_reviewers_on_review_rule_id"
  end

  create_table "settings", id: :serial, force: :cascade do |t|
    t.string "key"
    t.string "value"
    t.index ["key", "value"], name: "index_settings_on_key_and_value", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "login"
    t.string "email"
    t.string "name"
    t.string "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.jsonb "object"
    t.datetime "created_at"
    t.jsonb "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

end
