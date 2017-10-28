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

ActiveRecord::Schema.define(version: 20171028064755) do

  create_table "lists", force: :cascade do |t|
    t.string   "title",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "user_id",    limit: 4
  end

  add_index "lists", ["user_id"], name: "index_lists_on_user_id", using: :btree

  create_table "tasks", force: :cascade do |t|
    t.integer  "list_id",      limit: 4
    t.string   "title",        limit: 255
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.datetime "completed_at"
    t.integer  "duration",     limit: 4,   default: 0
  end

  add_index "tasks", ["list_id"], name: "index_tasks_on_list_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "first_name",           limit: 255
    t.string   "last_name",            limit: 255
    t.string   "email",                limit: 255
    t.string   "password_digest",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_reset_token", limit: 255
  end

  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["password_reset_token"], name: "index_users_on_password_reset_token", using: :btree

  add_foreign_key "tasks", "lists"
end
