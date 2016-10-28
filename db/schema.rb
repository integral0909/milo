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

ActiveRecord::Schema.define(version: 20161028033614) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", id: false, force: :cascade do |t|
    t.string   "plaid_acct_id"
    t.string   "account_name"
    t.string   "account_number"
    t.float    "available_balance"
    t.float    "current_balance"
    t.string   "institution_type"
    t.string   "name"
    t.string   "numbers"
    t.string   "acct_subtype"
    t.string   "acct_type"
    t.integer  "user_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.integer  "public_token_id"
    t.integer  "checking_id"
    t.string   "bank_account_number"
    t.string   "bank_routing_number"
  end

  create_table "checkings", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "plaid_acct_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "public_tokens", force: :cascade do |t|
    t.string "token"
    t.string "user_id"
  end

  create_table "token_data", force: :cascade do |t|
    t.integer  "expires_in"
    t.string   "scope"
    t.string   "account_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "access_token"
    t.string   "refresh_token"
  end

  create_table "transactions", id: false, force: :cascade do |t|
    t.string   "plaid_trans_id"
    t.string   "account_id"
    t.float    "amount"
    t.string   "trans_name"
    t.integer  "plaid_cat_id"
    t.string   "plaid_cat_type"
    t.date     "date"
    t.string   "vendor_address"
    t.string   "vendor_city"
    t.string   "vendor_state"
    t.string   "vendor_zip"
    t.float    "vendor_lat"
    t.float    "vendor_lon"
    t.boolean  "pending"
    t.string   "pending_transaction"
    t.integer  "name_score"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.float    "new_amount"
    t.float    "roundup"
    t.integer  "user_id"
  end

  create_table "transfers", force: :cascade do |t|
    t.string   "dwolla_url"
    t.string   "user_id"
    t.string   "roundup_count"
    t.string   "status"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "transfer_type"
    t.string   "roundup_amount"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "invited",                default: false
    t.boolean  "admin",                  default: false
    t.string   "referral_code"
    t.string   "name"
    t.string   "zip"
    t.string   "dwolla_id"
    t.string   "dwolla_funding_source"
    t.string   "mobile_number"
    t.string   "verification_code"
    t.boolean  "is_verified"
    t.boolean  "on_demand"
    t.boolean  "agreement"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "plaid_access_token"
    t.integer  "failed_attempts",        default: 0,     null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.integer  "account_balance"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

end
