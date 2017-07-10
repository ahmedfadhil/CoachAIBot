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

ActiveRecord::Schema.define(version: 20170710150204) do

  create_table "coach_users", force: :cascade do |t|
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "plans", force: :cascade do |t|
    t.string "name"
    t.text "desc"
    t.date "from_day"
    t.date "to_day"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "coach_user_id"
    t.index ["coach_user_id"], name: "index_plans_on_coach_user_id"
  end

  create_table "plans_users", force: :cascade do |t|
    t.integer "plan_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["plan_id"], name: "index_plans_users_on_plan_id"
    t.index ["user_id"], name: "index_plans_users_on_user_id"
  end

# Could not dump table "users" because of following StandardError
#   Unknown type 'jsonb' for column 'bot_command_data'

end
