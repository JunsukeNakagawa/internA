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

ActiveRecord::Schema.define(version: 20190114064539) do

  create_table "one_month_attendances", force: :cascade do |t|
    t.integer "application_user_id"
    t.integer "authorizer_user_id"
    t.date "application_date"
    t.integer "application_state", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin", default: false
    t.string "activation_digest"
    t.boolean "activated", default: false
    t.datetime "activated_at"
    t.string "reset_digest"
    t.datetime "reset_sent_at"
    t.time "basictime"
    t.time "workingtime"
    t.string "affiliation"
    t.datetime "working_time_End"
    t.integer "uid"
    t.boolean "superior"
    t.integer "cardID"
    t.integer "applied_last_time_user_id"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "works", force: :cascade do |t|
    t.datetime "attendance_time"
    t.datetime "leaving_time"
    t.date "day"
    t.datetime "workingtime"
    t.datetime "basictime"
    t.text "remarks"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.datetime "scheduled_end_time"
    t.boolean "checkbox"
    t.text "work_description"
    t.integer "check_by_boss"
    t.integer "authorizer_user_id"
    t.integer "application_state"
    t.text "overtime_work"
    t.datetime "edited_work_start"
    t.datetime "edited_work_end"
    t.integer "application_edit_state"
    t.integer "authorizer_user_id_of_attendance"
    t.datetime "before_edited_work_start"
    t.datetime "before_edited_work_end"
  end

end
