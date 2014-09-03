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

ActiveRecord::Schema.define(version: 20140903074124) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "applications", force: true do |t|
    t.string   "version"
    t.string   "appToken"
    t.datetime "validUntil"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "biz_account_services", force: true do |t|
    t.string   "pic",        null: false
    t.string   "api_data"
    t.integer  "profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "biz_account_services", ["profile_id"], name: "index_biz_account_services_on_profile_id", using: :btree

  create_table "change_rates", force: true do |t|
    t.integer  "CurrencyTo"
    t.integer  "CurrencyFrom"
    t.integer  "Rate"
    t.datetime "SetUpDate"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "feeds", force: true do |t|
    t.string   "message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "privacy"
    t.integer  "likes"
    t.string   "description"
    t.integer  "from_profile_id"
    t.integer  "to_profile_id"
    t.integer  "fType"
    t.date     "feed_date"
    t.integer  "amount"
    t.string   "currency",        limit: 3
  end

  create_table "global_settings", force: true do |t|
    t.string   "settings_key",   null: false
    t.string   "settings_value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

  create_table "iso_currencies", force: true do |t|
    t.string   "Alpha3Code",   limit: 3
    t.integer  "Numeric3Code"
    t.string   "IsoName"
    t.integer  "Precision"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
    t.string   "company_reg_number"
    t.string   "contact_person_name"
    t.string   "contact_person_position"
    t.date     "contact_person_date_of_birth"
    t.string   "contact_person_phone"
  end

  create_table "providers", force: true do |t|
    t.string   "pic"
    t.string   "apiData"
    t.integer  "application_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "providers", ["application_id"], name: "index_providers_on_application_id", using: :btree

  create_table "sessions", force: true do |t|
    t.string   "SessionId",      null: false
    t.datetime "TimeToDie"
    t.integer  "profile_id"
    t.integer  "application_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["application_id"], name: "index_sessions_on_application_id", using: :btree
  add_index "sessions", ["profile_id"], name: "index_sessions_on_profile_id", using: :btree

  create_table "wallet_messages", force: true do |t|
    t.string   "message"
    t.integer  "Request_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "wallet_messages", ["Request_id"], name: "index_wallet_messages_on_Request_id", using: :btree

  create_table "wallet_requests", force: true do |t|
    t.integer  "req_type"
    t.integer  "req_status"
    t.integer  "sourceWallet_id"
    t.integer  "targetWallet_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "wallets", force: true do |t|
    t.integer  "available"
    t.integer  "holded"
    t.integer  "Profile_id"
    t.integer  "IsoCurrency_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "wallets", ["IsoCurrency_id"], name: "index_wallets_on_IsoCurrency_id", using: :btree
  add_index "wallets", ["Profile_id"], name: "index_wallets_on_Profile_id", using: :btree

end
