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

ActiveRecord::Schema.define(version: 20141024110407) do

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

  create_table "entries", force: true do |t|
    t.integer  "payment_request_id",           null: false
    t.integer  "credit_profile_id",            null: false
    t.integer  "debt_profile_id",              null: false
    t.float    "amount",                       null: false
    t.string   "currency_id",        limit: 3, null: false
    t.integer  "operation_code",               null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "credit_wallet_id",             null: false
    t.integer  "debit_wallet_id",              null: false
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
    t.float    "amount"
    t.string   "currency",               limit: 3
    t.integer  "status",                            default: 0
    t.integer  "viewed",                            default: 0
    t.string   "type",                   limit: 40, default: "Feed"
    t.integer  "source_currency"
    t.float    "source_amount"
    t.integer  "rate_id"
    t.float    "conv_commission_amount"
    t.integer  "conv_commission_id"
    t.float    "commission_value"
    t.integer  "commission_currency"
    t.float    "commission_amount"
  end

  create_table "friends", id: false, force: true do |t|
    t.integer  "profile_id"
    t.integer  "friend_id"
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.string   "Name"
    t.integer  "Precision"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "IsoName"
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
    t.integer  "result"
    t.string   "message"
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
    t.integer  "friends_count",                default: 0
    t.boolean  "temp_account",                 default: false
    t.float    "available",                    default: 0.0
    t.float    "holded",                       default: 0.0
    t.string   "iso_currency",                 default: "EUR"
    t.integer  "lock_version",                 default: 0
  end

  create_table "providers", force: true do |t|
    t.string   "pic"
    t.string   "apiData"
    t.integer  "application_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "providers", ["application_id"], name: "index_providers_on_application_id", using: :btree

  create_table "push_tokens", force: true do |t|
    t.string   "token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "profile_id"
  end

  add_index "push_tokens", ["profile_id"], name: "index_push_tokens_on_profile_id", using: :btree

  create_table "rpush_apps", force: true do |t|
    t.string   "name",                                null: false
    t.string   "environment"
    t.text     "certificate"
    t.string   "password"
    t.integer  "connections",             default: 1, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",                                null: false
    t.string   "auth_key"
    t.string   "client_id"
    t.string   "client_secret"
    t.string   "access_token"
    t.datetime "access_token_expiration"
  end

  create_table "rpush_feedback", force: true do |t|
    t.string   "device_token", limit: 64, null: false
    t.datetime "failed_at",               null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "app_id"
  end

  add_index "rpush_feedback", ["device_token"], name: "index_rpush_feedback_on_device_token", using: :btree

  create_table "rpush_notifications", force: true do |t|
    t.integer  "badge"
    t.string   "device_token",      limit: 64
    t.string   "sound",                        default: "default"
    t.string   "alert"
    t.text     "data"
    t.integer  "expiry",                       default: 86400
    t.boolean  "delivered",                    default: false,     null: false
    t.datetime "delivered_at"
    t.boolean  "failed",                       default: false,     null: false
    t.datetime "failed_at"
    t.integer  "error_code"
    t.text     "error_description"
    t.datetime "deliver_after"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "alert_is_json",                default: false
    t.string   "type",                                             null: false
    t.string   "collapse_key"
    t.boolean  "delay_while_idle",             default: false,     null: false
    t.text     "registration_ids"
    t.integer  "app_id",                                           null: false
    t.integer  "retries",                      default: 0
    t.string   "uri"
    t.datetime "fail_after"
    t.boolean  "processing",                   default: false,     null: false
    t.integer  "priority"
    t.text     "url_args"
    t.string   "category"
  end

  add_index "rpush_notifications", ["delivered", "failed"], name: "index_rpush_notifications_multi", where: "((NOT delivered) AND (NOT failed))", using: :btree

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
    t.string   "token",           null: false
    t.integer  "feed_id"
  end

  add_index "wallet_requests", ["feed_id"], name: "index_wallet_requests_on_feed_id", using: :btree

  create_table "wallets", force: true do |t|
    t.float    "available"
    t.float    "holded"
    t.integer  "profile_id"
    t.integer  "IsoCurrency_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "wallets", ["IsoCurrency_id"], name: "index_wallets_on_IsoCurrency_id", using: :btree
  add_index "wallets", ["profile_id"], name: "index_wallets_on_profile_id", using: :btree

end
