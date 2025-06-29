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

ActiveRecord::Schema[8.0].define(version: 2025_06_29_000500) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "asset_prices", force: :cascade do |t|
    t.bigint "asset_id", null: false
    t.decimal "price", precision: 15, scale: 2, null: false
    t.datetime "synced_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["asset_id"], name: "index_asset_prices_on_asset_id"
  end

  create_table "assets", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "category_id", null: false
    t.string "type"
    t.index ["category_id"], name: "index_assets_on_category_id"
    t.index ["type"], name: "index_assets_on_type"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "investment_transactions", force: :cascade do |t|
    t.bigint "asset_id", null: false
    t.string "transaction_type", null: false
    t.date "date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.decimal "quantity", precision: 15, scale: 4, null: false
    t.string "unit", null: false
    t.decimal "nav", precision: 15, scale: 4, null: false
    t.decimal "fee", precision: 15, scale: 2
    t.decimal "total_amount", precision: 15, scale: 2
    t.index ["asset_id"], name: "index_investment_transactions_on_asset_id"
    t.index ["user_id"], name: "index_investment_transactions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "encrypted_password"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "asset_prices", "assets"
  add_foreign_key "assets", "categories"
  add_foreign_key "investment_transactions", "assets"
  add_foreign_key "investment_transactions", "users"
end
