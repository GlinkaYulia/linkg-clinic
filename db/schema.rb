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

ActiveRecord::Schema[8.1].define(version: 2026_11_01_000007) do
  create_table "appointment_services", force: :cascade do |t|
    t.integer "appointment_id", null: false
    t.integer "service_id", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["appointment_id", "service_id"], name: "index_appointment_services_on_appointment_id_and_service_id", unique: true
    t.index ["appointment_id"], name: "index_appointment_services_on_appointment_id"
    t.index ["service_id"], name: "index_appointment_services_on_service_id"
  end

  create_table "appointments", force: :cascade do |t|
    t.integer "patient_id", null: false
    t.integer "doctor_profile_id", null: false
    t.datetime "starts_at", null: false
    t.integer "status", default: 0, null: false
    t.datetime "cancelled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "delivery_method", default: 0, null: false
    t.string "delivery_address"
    t.decimal "delivery_fee", precision: 10, scale: 2, default: "0.0", null: false
    t.integer "payment_method", default: 0, null: false
    t.integer "payment_status", default: 0, null: false
    t.datetime "paid_at"
    t.string "payment_reference"
    t.decimal "total_price", precision: 10, scale: 2, default: "0.0", null: false
    t.text "comment"
    t.index ["doctor_profile_id", "starts_at"], name: "index_appointments_unique_active_slot", unique: true, where: "status <> 2"
    t.index ["doctor_profile_id"], name: "index_appointments_on_doctor_profile_id"
    t.index ["patient_id"], name: "index_appointments_on_patient_id"
    t.index ["starts_at"], name: "index_appointments_on_starts_at"
    t.index ["status"], name: "index_appointments_on_status"
  end

  create_table "doctor_profiles", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "specialty_id", null: false
    t.string "room", null: false
    t.text "bio"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "consultation_price", precision: 10, scale: 2, default: "0.0", null: false
    t.index ["specialty_id"], name: "index_doctor_profiles_on_specialty_id"
    t.index ["user_id"], name: "index_doctor_profiles_on_user_id", unique: true
  end

  create_table "feedback_messages", force: :cascade do |t|
    t.integer "user_id"
    t.string "name", null: false
    t.string "email", null: false
    t.string "subject", null: false
    t.text "body", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_feedback_messages_on_user_id"
  end

  create_table "medical_records", force: :cascade do |t|
    t.integer "appointment_id", null: false
    t.text "complaints"
    t.text "diagnosis"
    t.text "prescription"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["appointment_id"], name: "index_medical_records_on_appointment_id", unique: true
  end

  create_table "reviews", force: :cascade do |t|
    t.integer "appointment_id", null: false
    t.integer "patient_id", null: false
    t.integer "doctor_profile_id", null: false
    t.integer "rating", null: false
    t.text "body", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["appointment_id"], name: "index_reviews_on_appointment_id", unique: true
    t.index ["doctor_profile_id"], name: "index_reviews_on_doctor_profile_id"
    t.index ["patient_id"], name: "index_reviews_on_patient_id"
  end

  create_table "services", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.decimal "price", precision: 10, scale: 2, default: "0.0", null: false
    t.integer "specialty_id"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_services_on_name", unique: true
    t.index ["specialty_id"], name: "index_services_on_specialty_id"
  end

  create_table "specialties", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_specialties_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "full_name", null: false
    t.string "email", null: false
    t.string "phone"
    t.date "birth_date"
    t.string "password_digest", null: false
    t.integer "role", default: 0, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "locked_until"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "working_hours", force: :cascade do |t|
    t.integer "doctor_profile_id", null: false
    t.integer "weekday", null: false
    t.string "start_time", null: false
    t.string "end_time", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["doctor_profile_id", "weekday"], name: "index_working_hours_on_doctor_profile_id_and_weekday", unique: true
    t.index ["doctor_profile_id"], name: "index_working_hours_on_doctor_profile_id"
  end

  add_foreign_key "appointment_services", "appointments"
  add_foreign_key "appointment_services", "services"
  add_foreign_key "appointments", "doctor_profiles"
  add_foreign_key "appointments", "users", column: "patient_id"
  add_foreign_key "doctor_profiles", "specialties"
  add_foreign_key "doctor_profiles", "users"
  add_foreign_key "feedback_messages", "users"
  add_foreign_key "medical_records", "appointments"
  add_foreign_key "reviews", "appointments"
  add_foreign_key "reviews", "doctor_profiles"
  add_foreign_key "reviews", "users", column: "patient_id"
  add_foreign_key "services", "specialties"
  add_foreign_key "working_hours", "doctor_profiles"
end
