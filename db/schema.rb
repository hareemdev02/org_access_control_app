# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2025_07_09_153411) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "organization_analytics", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.integer "total_members", default: 0, null: false
    t.integer "admin_count", default: 0, null: false
    t.jsonb "age_group_breakdown", default: {}
    t.decimal "participation_rate", precision: 5, scale: 2, default: "0.0", null: false
    t.datetime "generated_at", null: false
    t.string "report_period"
    t.datetime "period_start"
    t.datetime "period_end"
    t.integer "new_members_count", default: 0
    t.integer "active_members_count", default: 0
    t.integer "active_users_7_days", default: 0
    t.integer "active_users_30_days", default: 0
    t.integer "new_members_this_month", default: 0
    t.jsonb "members_by_role", default: {}
    t.decimal "average_age", precision: 4, scale: 1
    t.decimal "minor_percentage", precision: 5, scale: 2
    t.jsonb "additional_metrics", default: {}
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["generated_at"], name: "index_organization_analytics_on_generated_at"
    t.index ["organization_id", "generated_at"], name: "index_org_analytics_on_org_id_and_generated_at"
    t.index ["organization_id"], name: "index_organization_analytics_on_organization_id"
    t.index ["report_period"], name: "index_organization_analytics_on_report_period"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name", null: false
    t.string "domain", null: false
    t.text "description"
    t.string "participation_type", default: "private"
    t.boolean "active", default: true
    t.jsonb "settings", default: {}
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["active"], name: "index_organizations_on_active"
    t.index ["domain"], name: "index_organizations_on_domain", unique: true
    t.index ["name"], name: "index_organizations_on_name", unique: true
    t.index ["participation_type"], name: "index_organizations_on_participation_type"
  end

  create_table "parental_consents", force: :cascade do |t|
    t.bigint "parent_id", null: false
    t.bigint "child_id", null: false
    t.boolean "approved", default: false
    t.date "consent_date", null: false
    t.date "expiry_date", null: false
    t.bigint "approved_by_id"
    t.datetime "approved_at"
    t.bigint "revoked_by_id"
    t.datetime "revoked_at"
    t.text "notes"
    t.jsonb "consent_details", default: {}
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["approved"], name: "index_parental_consents_on_approved"
    t.index ["child_id"], name: "index_parental_consents_on_child_id", unique: true
    t.index ["consent_date"], name: "index_parental_consents_on_consent_date"
    t.index ["expiry_date"], name: "index_parental_consents_on_expiry_date"
  end

  create_table "participation_rules", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.string "age_group", null: false
    t.integer "minimum_age", null: false
    t.integer "maximum_age", null: false
    t.boolean "enabled", default: true
    t.boolean "requires_parental_consent", default: false
    t.string "content_filtering_level", default: "minimal"
    t.jsonb "participation_restrictions", default: []
    t.text "description"
    t.jsonb "settings", default: {}
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["content_filtering_level"], name: "index_participation_rules_on_content_filtering_level"
    t.index ["enabled"], name: "index_participation_rules_on_enabled"
    t.index ["organization_id", "age_group"], name: "index_participation_rules_on_organization_id_and_age_group", unique: true
    t.index ["organization_id"], name: "index_participation_rules_on_organization_id"
    t.index ["requires_parental_consent"], name: "index_participation_rules_on_requires_parental_consent"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource_type_and_resource_id"
  end

  create_table "user_roles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "role_id", null: false
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["resource_type", "resource_id"], name: "index_user_roles_on_resource_type_and_resource_id"
    t.index ["role_id"], name: "index_user_roles_on_role_id"
    t.index ["user_id", "role_id", "resource_type", "resource_id"], name: "index_user_roles_on_user_role_resource", unique: true
    t.index ["user_id"], name: "index_user_roles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.date "date_of_birth", null: false
    t.integer "age"
    t.string "phone_number"
    t.text "bio"
    t.string "avatar_url"
    t.bigint "organization_id"
    t.boolean "email_verified", default: false
    t.boolean "phone_verified", default: false
    t.boolean "identity_verified", default: false
    t.boolean "active", default: true
    t.datetime "last_login_at"
    t.inet "last_login_ip"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["active"], name: "index_users_on_active"
    t.index ["age"], name: "index_users_on_age"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["email_verified"], name: "index_users_on_email_verified"
    t.index ["identity_verified"], name: "index_users_on_identity_verified"
    t.index ["organization_id"], name: "index_users_on_organization_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  add_foreign_key "organization_analytics", "organizations"
  add_foreign_key "parental_consents", "users", column: "approved_by_id"
  add_foreign_key "parental_consents", "users", column: "child_id"
  add_foreign_key "parental_consents", "users", column: "parent_id"
  add_foreign_key "parental_consents", "users", column: "revoked_by_id"
  add_foreign_key "participation_rules", "organizations"
  add_foreign_key "user_roles", "roles"
  add_foreign_key "user_roles", "users"
  add_foreign_key "users", "organizations"
end
