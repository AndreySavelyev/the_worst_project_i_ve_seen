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

ActiveRecord::Schema.define(version: 20140730031719) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "applications", force: true do |t|
    t.string   "version"
    t.string   "appToken"
    t.datetime "validUntil"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "feeds", force: true do |t|
    t.date     "feedDate"
    t.string   "message"
    t.string   "feedType"
    t.integer  "profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "feeds", ["profile_id"], name: "index_feeds_on_profile_id", using: :btree

  create_table "hot_offers", force: true do |t|
    t.string   "title"
    t.string   "currency"
    t.string   "pic_url"
    t.integer  "price"
    t.integer  "profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "hot_offers", ["profile_id"], name: "index_hot_offers_on_profile_id", using: :btree

  create_table "profiles", force: true do |t|
    t.string   "user_token"
    t.string   "fb_token"
    t.string   "pic_url"
    t.string   "name"
    t.string   "surname"
    t.string   "phone"
    t.string   "iban"
    t.string   "reg_num"
    t.string   "company_name"
    t.string   "email"
    t.string   "password"
    t.string   "salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "reg_token"
    t.integer  "confirm_type"
    t.string   "web_site"
    t.string   "address"
    t.integer  "wallet_type"
    t.date     "birthday"
  end

  create_table "providers", force: true do |t|
    t.string   "pic"
    t.string   "apiData"
    t.integer  "application_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "providers", ["application_id"], name: "index_providers_on_application_id", using: :btree

end
