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

ActiveRecord::Schema.define(version: 20140222113013) do

  create_table "admins", force: true do |t|
    t.integer "user_id"
    t.integer "feed_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admins", ["feed_id"], name: "index_admins_on_feed_id"
  add_index "admins", ["user_id"], name: "index_admins_on_user_id"

  create_table "devices", force: true do |t|
    t.string "identifier"
    t.string "name"
    t.string "password"
    t.string "comment"
    t.integer "current_track", default: 0
    t.boolean "public", default: false
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "devices", ["user_id"], name: "index_devices_on_user_id"

  create_table "feeds", force: true do |t|
    t.string "name"
    t.string "comment"
    t.boolean "public", default: true
    t.string "identifier"
    t.string "read_key"
    t.string "write_key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "readers", force: true do |t|
    t.integer "user_id"
    t.integer "feed_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "readers", ["feed_id"], name: "index_readers_on_feed_id"
  add_index "readers", ["user_id"], name: "index_readers_on_user_id"

  create_table "reading_devices", force: true do |t|
    t.integer "device_id"
    t.integer "feed_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reading_devices", ["device_id"], name: "index_reading_devices_on_device_id"
  add_index "reading_devices", ["feed_id"], name: "index_reading_devices_on_feed_id"

  create_table "shared_data", force: true do |t|
    t.string "time_stamp"
    t.string "json_data"
    t.integer "device_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shared_data", ["device_id"], name: "index_shared_data_on_device_id"

  create_table "shared_data_feeds", force: true do |t|
    t.integer "shared_data_id"
    t.integer "feed_id"
  end

  create_table "users", force: true do |t|
    t.string "username"
    t.string "password"
    t.string "mail"
    t.string "name"
    t.string "comment"
    t.boolean "public_email", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "writers", force: true do |t|
    t.integer "user_id"
    t.integer "feed_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "writers", ["feed_id"], name: "index_writers_on_feed_id"
  add_index "writers", ["user_id"], name: "index_writers_on_user_id"

  create_table "writing_devices", force: true do |t|
    t.integer "device_id"
    t.integer "feed_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "writing_devices", ["device_id"], name: "index_writing_devices_on_device_id"
  add_index "writing_devices", ["feed_id"], name: "index_writing_devices_on_feed_id"

end
