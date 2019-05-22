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

ActiveRecord::Schema.define(version: 20190510190529) do

  create_table "bookings", force: :cascade do |t|
    t.string   "organization"
    t.string   "book_number"
    t.string   "supplier"
    t.string   "reference"
    t.decimal  "amount"
    t.string   "barcode"
    t.integer  "uploaded",     default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "crono_jobs", force: :cascade do |t|
    t.string   "job_id",            null: false
    t.text     "log"
    t.datetime "last_performed_at"
    t.boolean  "healthy"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "crono_jobs", ["job_id"], name: "index_crono_jobs_on_job_id", unique: true

  create_table "invoices", force: :cascade do |t|
    t.string   "organization"
    t.string   "book_number"
    t.string   "approver"
    t.string   "file_name"
    t.integer  "uploaded"
    t.string   "jira_id"
    t.string   "jira_status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "result"
    t.integer  "organization_id"
  end

  add_index "invoices", ["book_number"], name: "index_invoices_on_book_number"

  create_table "invoices_organizations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "organizations", force: :cascade do |t|
    t.string   "name",                                       null: false
    t.string   "default_approver"
    t.string   "backend",          default: "jira",          null: false
    t.string   "viiper_dir_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "backends",         default: "---\n- jira\n"
  end

  create_table "users", force: :cascade do |t|
    t.string   "username",                      null: false
    t.boolean  "admin",         default: false
    t.boolean  "reader",        default: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "password_hash"
    t.string   "password_salt"
  end

  add_index "users", ["username"], name: "index_users_on_username", unique: true

end
