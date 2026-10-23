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

ActiveRecord::Schema[8.0].define(version: 2026_10_23_180000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "companies", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower((name)::text)", name: "index_companies_on_lower_name", unique: true
  end

  create_table "company_settings", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "primary_color", default: "#0f3d4c", null: false
    t.string "accent_color", default: "#b8612d", null: false
    t.string "background_color", default: "#f4f1ea", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_company_settings_on_company_id", unique: true
  end

  create_table "departments", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "company_id", null: false
    t.index "company_id, lower((name)::text)", name: "index_departments_on_company_and_lower_name", unique: true
    t.index ["company_id"], name: "index_departments_on_company_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "name", null: false
    t.string "city", null: false
    t.string "country", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "company_id", null: false
    t.index ["company_id"], name: "index_locations_on_company_id"
    t.index ["country"], name: "index_locations_on_country"
  end

  create_table "password_reset_requests", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.bigint "user_id", null: false
    t.bigint "resolved_by_id"
    t.integer "status", default: 0, null: false
    t.datetime "requested_at", null: false
    t.datetime "resolved_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_password_reset_requests_on_company_id"
    t.index ["resolved_by_id"], name: "index_password_reset_requests_on_resolved_by_id"
    t.index ["user_id"], name: "index_one_pending_password_reset_per_user", unique: true, where: "(status = 0)"
    t.index ["user_id"], name: "index_password_reset_requests_on_user_id"
  end

  create_table "salaries", force: :cascade do |t|
    t.bigint "employee_id", null: false
    t.string "currency", limit: 3, null: false
    t.integer "salary_type", null: false
    t.date "effective_on", null: false
    t.boolean "current", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "amount_cents", null: false
    t.index ["effective_on"], name: "index_salaries_on_effective_on"
    t.index ["employee_id", "salary_type"], name: "index_salaries_one_current_per_type", unique: true, where: "(current = true)"
    t.index ["employee_id"], name: "index_salaries_on_employee_id"
    t.index ["salary_type", "current"], name: "index_salaries_on_salary_type_and_current"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "encrypted_password", null: false
    t.integer "role", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "employee_id"
    t.string "job_title"
    t.date "hire_date"
    t.bigint "department_id"
    t.bigint "location_id"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "work_mode"
    t.bigint "company_id"
    t.index "lower((email)::text)", name: "index_super_admins_on_lower_email", unique: true, where: "(company_id IS NULL)"
    t.index "lower((email)::text), company_id", name: "index_users_on_company_and_lower_email", unique: true, where: "(company_id IS NOT NULL)"
    t.index ["active"], name: "index_users_on_active"
    t.index ["company_id", "employee_id"], name: "index_users_on_company_and_employee_id", unique: true, where: "(employee_id IS NOT NULL)"
    t.index ["company_id"], name: "index_users_on_company_id"
    t.index ["department_id"], name: "index_users_on_department_id"
    t.index ["last_name", "first_name"], name: "index_users_on_last_name_and_first_name"
    t.index ["location_id"], name: "index_users_on_location_id"
    t.index ["role"], name: "index_users_on_role"
    t.index ["work_mode"], name: "index_users_on_work_mode"
  end

  create_table "versions", force: :cascade do |t|
    t.string "whodunnit"
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.jsonb "object"
    t.jsonb "object_changes"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "company_settings", "companies"
  add_foreign_key "departments", "companies"
  add_foreign_key "locations", "companies"
  add_foreign_key "password_reset_requests", "companies"
  add_foreign_key "password_reset_requests", "users"
  add_foreign_key "password_reset_requests", "users", column: "resolved_by_id"
  add_foreign_key "salaries", "users", column: "employee_id"
  add_foreign_key "users", "companies"
  add_foreign_key "users", "departments"
  add_foreign_key "users", "locations"
end
