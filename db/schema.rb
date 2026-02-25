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

ActiveRecord::Schema[8.1].define(version: 2026_02_25_215742) do
  create_table "about_pages", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.integer "position"
    t.string "section_type", default: "mon_parcours", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["section_type"], name: "index_about_pages_on_section_type"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "cart_products", force: :cascade do |t|
    t.integer "cart_id", null: false
    t.datetime "created_at", null: false
    t.integer "product_id", null: false
    t.integer "quantity"
    t.decimal "unit_price"
    t.datetime "updated_at", null: false
    t.index ["cart_id"], name: "index_cart_products_on_cart_id"
    t.index ["product_id"], name: "index_cart_products_on_product_id"
  end

  create_table "carts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "status"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_carts_on_user_id"
  end

  create_table "company_informations", force: :cascade do |t|
    t.text "about_mon_parcours_description"
    t.string "about_mon_parcours_title"
    t.text "about_pontius_description"
    t.string "about_pontius_title"
    t.text "about_principal_description"
    t.string "about_principal_title"
    t.text "additional_info"
    t.string "address_line1"
    t.string "address_line2"
    t.string "city"
    t.string "country"
    t.datetime "created_at", null: false
    t.string "email"
    t.text "footer_description"
    t.string "home_banner_primary_cta_label"
    t.string "home_banner_secondary_cta_label"
    t.string "home_banner_subtitle"
    t.string "home_banner_title"
    t.text "home_highlight_1_description"
    t.string "home_highlight_1_title"
    t.text "home_highlight_2_description"
    t.string "home_highlight_2_title"
    t.text "home_highlight_3_description"
    t.string "home_highlight_3_title"
    t.text "home_highlight_4_description"
    t.string "home_highlight_4_title"
    t.string "legal_name"
    t.string "phone"
    t.string "siret"
    t.datetime "updated_at", null: false
    t.string "vat_number"
    t.string "zipcode"
  end

  create_table "contacts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "image"
    t.text "message"
    t.string "name"
    t.string "subject"
    t.datetime "updated_at", null: false
  end

  create_table "events", force: :cascade do |t|
    t.string "category"
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "end_date"
    t.datetime "event_date"
    t.string "image_url"
    t.string "location"
    t.string "title"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "home_pages", force: :cascade do |t|
    t.string "bloc_type", default: "custom", null: false
    t.string "button_label"
    t.text "content"
    t.datetime "created_at", null: false
    t.integer "position"
    t.string "shop_scope", default: "first", null: false
    t.integer "target_id"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["target_id"], name: "index_home_pages_on_target_id"
  end

  create_table "order_products", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "order_id", null: false
    t.integer "product_id", null: false
    t.integer "quantity", default: 1
    t.decimal "unit_price"
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_products_on_order_id"
    t.index ["product_id"], name: "index_order_products_on_product_id"
  end

  create_table "orders", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "order_date"
    t.string "status"
    t.decimal "total_amount"
    t.string "tracking_number"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "page_metas", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "meta_description"
    t.string "meta_title"
    t.string "page_key", null: false
    t.datetime "updated_at", null: false
    t.index ["page_key"], name: "index_page_metas_on_page_key", unique: true
  end

  create_table "privacy_pages", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.integer "position"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "products", force: :cascade do |t|
    t.string "category"
    t.datetime "created_at", null: false
    t.text "description"
    t.text "highlight_1_description"
    t.boolean "highlight_1_enabled", default: true, null: false
    t.string "highlight_1_title"
    t.text "highlight_2_description"
    t.boolean "highlight_2_enabled", default: true, null: false
    t.string "highlight_2_title"
    t.text "highlight_3_description"
    t.boolean "highlight_3_enabled", default: true, null: false
    t.string "highlight_3_title"
    t.decimal "price"
    t.boolean "show_product_highlights", default: true, null: false
    t.integer "stock"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "repair_pages", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.integer "position"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "terms_pages", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.integer "position"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "address"
    t.boolean "cgu_accepted", default: false, null: false
    t.string "city"
    t.string "country"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name"
    t.boolean "is_admin", default: false
    t.string "last_name"
    t.string "phone"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.string "zipcode"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "cart_products", "carts"
  add_foreign_key "cart_products", "products"
  add_foreign_key "carts", "users"
  add_foreign_key "events", "users"
  add_foreign_key "order_products", "orders"
  add_foreign_key "order_products", "products"
  add_foreign_key "orders", "users", on_delete: :nullify
end
