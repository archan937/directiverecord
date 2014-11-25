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

ActiveRecord::Schema.define(version: 0) do

  create_table "customers", force: true do |t|
    t.integer "sales_rep_employee_id"
    t.string  "name",                  limit: 50
    t.string  "contact_first_name",    limit: 50
    t.string  "contact_last_name",     limit: 50
    t.string  "phone",                 limit: 50
    t.string  "address_line1",         limit: 50
    t.string  "address_line2",         limit: 50
    t.string  "postal_code",           limit: 15
    t.string  "city",                  limit: 50
    t.string  "state",                 limit: 50
    t.string  "country",               limit: 50
    t.decimal "credit_limit",                     precision: 10, scale: 2
  end

  add_index "customers", ["sales_rep_employee_id"], name: "sales_rep_employee_id", using: :btree

  create_table "customers_tags", id: false, force: true do |t|
    t.integer "customer_id"
    t.integer "tag_id"
  end

  add_index "customers_tags", ["customer_id", "tag_id"], name: "customers_tags", using: :btree

  create_table "employees", force: true do |t|
    t.integer "office_id"
    t.integer "reportee_id"
    t.string  "job_title",   limit: 50
    t.string  "first_name",  limit: 50
    t.string  "last_name",   limit: 50
    t.string  "email",       limit: 100
  end

  add_index "employees", ["office_id"], name: "office_id", using: :btree
  add_index "employees", ["reportee_id"], name: "reportee_id", using: :btree

  create_table "offices", force: true do |t|
    t.string "city",          limit: 50
    t.string "phone",         limit: 50
    t.string "address_line1", limit: 50
    t.string "address_line2", limit: 50
    t.string "postal_code",   limit: 15
    t.string "state",         limit: 50
    t.string "country",       limit: 50
    t.string "territory",     limit: 10
  end

  create_table "order_details", force: true do |t|
    t.integer "order_id"
    t.integer "product_id"
    t.integer "order_line_number", limit: 2
    t.integer "quantity_ordered"
    t.decimal "price_each",                  precision: 10, scale: 2
  end

  add_index "order_details", ["order_id"], name: "order_details_ibfk_1", using: :btree
  add_index "order_details", ["product_id"], name: "product_id", using: :btree

  create_table "orders", force: true do |t|
    t.integer "customer_id"
    t.date    "order_date"
    t.date    "required_date"
    t.date    "shipped_date"
    t.string  "status",        limit: 15
    t.text    "comments"
  end

  add_index "orders", ["customer_id"], name: "customer_id", using: :btree

  create_table "payments", force: true do |t|
    t.integer "customer_id"
    t.string  "check_number", limit: 50
    t.date    "date"
    t.decimal "amount",                  precision: 10, scale: 2
  end

  add_index "payments", ["customer_id"], name: "payments_ibfk_1", using: :btree

  create_table "product_lines", force: true do |t|
    t.string "name",        limit: 50
    t.string "description", limit: 4000
  end

  create_table "products", force: true do |t|
    t.integer "product_line_id"
    t.string  "code",              limit: 15
    t.string  "name",              limit: 70
    t.string  "scale",             limit: 10
    t.string  "vendor",            limit: 50
    t.text    "description"
    t.integer "quantity_in_stock", limit: 2
    t.decimal "price",                        precision: 10, scale: 2
    t.decimal "msrp",                         precision: 10, scale: 2
  end

  add_index "products", ["product_line_id"], name: "product_line_id", using: :btree

  create_table "tags", force: true do |t|
    t.string "name", limit: 50
  end

end
