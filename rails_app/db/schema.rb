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

ActiveRecord::Schema.define(version: 20140110144300) do

  create_table "devices", force: true do |t|
    t.string   "identifier"
    t.string   "name"
    t.string   "password"
    t.string   "comment"
    t.integer  "current_track", default: 0
    t.boolean  "public",        default: false
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "devices", ["user_id"], name: "index_devices_on_user_id"

  create_table "devices_users", force: true do |t|
    t.integer "user_id"
    t.integer "device_id"
  end

  create_table "users", force: true do |t|
    t.string   "username"
    t.string   "password"
    t.string   "mail"
    t.string   "name"
    t.string   "comment"
    t.boolean  "public_email", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
