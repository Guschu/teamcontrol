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

ActiveRecord::Schema.define(version: 20160222134416) do

  create_table "attendances", force: :cascade do |t|
    t.integer  "team_id",    limit: 4
    t.integer  "driver_id",  limit: 4
    t.string   "tag_id",     limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "attendances", ["driver_id"], name: "index_attendances_on_driver_id", using: :btree
  add_index "attendances", ["tag_id"], name: "index_attendances_on_tag_id", using: :btree
  add_index "attendances", ["team_id"], name: "index_attendances_on_team_id", using: :btree

  create_table "drivers", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "events", force: :cascade do |t|
    t.integer  "team_id",    limit: 4
    t.integer  "driver_id",  limit: 4
    t.integer  "mode",       limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "events", ["driver_id"], name: "index_events_on_driver_id", using: :btree
  add_index "events", ["team_id"], name: "index_events_on_team_id", using: :btree

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",           limit: 255, null: false
    t.integer  "sluggable_id",   limit: 4,   null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope",          limit: 255
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "races", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.integer  "duration",       limit: 4
    t.integer  "max_drive",      limit: 4
    t.integer  "max_turn",       limit: 4
    t.integer  "break_time",     limit: 4
    t.integer  "waiting_period", limit: 4
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "slug",           limit: 255
    t.integer  "state",          limit: 4,   default: 0
    t.integer  "mode",           limit: 4,   default: 0
    t.date     "scheduled"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.integer  "min_turn",       limit: 4
  end

  add_index "races", ["mode"], name: "index_races_on_mode", using: :btree
  add_index "races", ["slug"], name: "index_races_on_slug", using: :btree

  create_table "stations", force: :cascade do |t|
    t.string   "token",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "stations", ["token"], name: "index_stations_on_token", using: :btree

  create_table "teams", force: :cascade do |t|
    t.integer  "race_id",           limit: 4
    t.string   "name",              limit: 255
    t.string   "logo_file_name",    limit: 255
    t.string   "logo_content_type", limit: 255
    t.integer  "logo_file_size",    limit: 4
    t.datetime "logo_updated_at"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "team_token",        limit: 255
    t.integer  "position",          limit: 4
    t.string   "team_lead",         limit: 255
    t.integer  "attendances_count", limit: 4
  end

  add_index "teams", ["race_id"], name: "index_teams_on_race_id", using: :btree
  add_index "teams", ["team_token"], name: "index_teams_on_team_token", using: :btree

  create_table "turns", force: :cascade do |t|
    t.integer  "team_id",    limit: 4
    t.integer  "driver_id",  limit: 4
    t.integer  "duration",   limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "turns", ["driver_id"], name: "index_turns_on_driver_id", using: :btree
  add_index "turns", ["team_id"], name: "index_turns_on_team_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "attendances", "drivers"
  add_foreign_key "attendances", "teams"
  add_foreign_key "events", "drivers"
  add_foreign_key "events", "teams"
  add_foreign_key "teams", "races"
  add_foreign_key "turns", "drivers"
  add_foreign_key "turns", "teams"
end
