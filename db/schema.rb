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

ActiveRecord::Schema[8.0].define(version: 2025_06_26_000700) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "asset_labels", force: :cascade do |t|
    t.bigint "asset_id", null: false
    t.bigint "label_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["asset_id", "label_id"], name: "index_asset_labels_on_asset_id_and_label_id", unique: true
    t.index ["asset_id"], name: "index_asset_labels_on_asset_id"
    t.index ["label_id"], name: "index_asset_labels_on_label_id"
  end

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
    t.bigint "user_id", null: false
    t.index ["category_id"], name: "index_assets_on_category_id"
    t.index ["user_id"], name: "index_assets_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_categories_on_user_id"
  end

  create_table "investment_transactions", force: :cascade do |t|
    t.bigint "asset_id", null: false
    t.decimal "amount", null: false
    t.string "transaction_type", null: false
    t.date "date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["asset_id"], name: "index_investment_transactions_on_asset_id"
    t.index ["user_id"], name: "index_investment_transactions_on_user_id"
  end

  create_table "labels", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_labels_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "encrypted_password"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "asset_labels", "assets"
  add_foreign_key "asset_labels", "labels"
  add_foreign_key "asset_prices", "assets"
  add_foreign_key "assets", "categories"
  add_foreign_key "assets", "users"
  add_foreign_key "categories", "users"
  add_foreign_key "investment_transactions", "assets"
  add_foreign_key "investment_transactions", "users"
  add_foreign_key "labels", "users"
end
