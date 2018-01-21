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

ActiveRecord::Schema.define(version: 20180108130648) do

  create_table "activities", force: :cascade do |t|
    t.string "name"
    t.string "desc"
    t.string "a_type"
    t.integer "n_times"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "category"
  end

  create_table "answers", force: :cascade do |t|
    t.text "text"
    t.integer "question_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_answers_on_question_id"
  end

  create_table "bot_commands", force: :cascade do |t|
    t.string "data"
    t.integer "user_id"
    t.index ["user_id"], name: "index_bot_commands_on_user_id"
  end

  create_table "chats", force: :cascade do |t|
    t.integer "coach_user_id"
    t.integer "user_id"
    t.string "text"
    t.boolean "direction"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["coach_user_id"], name: "index_chats_on_coach_user_id"
    t.index ["user_id"], name: "index_chats_on_user_id"
  end

  create_table "coach_users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.index ["email"], name: "index_coach_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_coach_users_on_reset_password_token", unique: true
  end

  create_table "communications", force: :cascade do |t|
    t.integer "c_type"
    t.string "text"
    t.datetime "read_at"
    t.integer "user_id"
    t.integer "coach_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["coach_user_id"], name: "index_communications_on_coach_user_id"
    t.index ["user_id"], name: "index_communications_on_user_id"
  end

  create_table "crono_jobs", force: :cascade do |t|
    t.string "job_id", null: false
    t.text "log", limit: 1073741823
    t.datetime "last_performed_at"
    t.boolean "healthy"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id"], name: "index_crono_jobs_on_job_id", unique: true
  end

  create_table "daily_logs", force: :cascade do |t|
    t.integer "user_id"
    t.float "distance"
    t.integer "calories"
    t.integer "steps"
    t.integer "sleep"
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_daily_logs_on_user_id"
  end

  create_table "feedbacks", force: :cascade do |t|
    t.text "answer"
    t.date "date"
    t.integer "question_id"
    t.integer "notification_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notification_id"], name: "index_feedbacks_on_notification_id"
    t.index ["question_id"], name: "index_feedbacks_on_question_id"
  end

  create_table "invitations", force: :cascade do |t|
    t.integer "user_id"
    t.integer "questionnaire_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["questionnaire_id"], name: "index_invitations_on_questionnaire_id"
    t.index ["user_id"], name: "index_invitations_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.boolean "default"
    t.date "date"
    t.time "time"
    t.boolean "sent"
    t.integer "planning_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "n_type"
    t.integer "done"
    t.index ["planning_id"], name: "index_notifications_on_planning_id"
  end

  create_table "options", force: :cascade do |t|
    t.string "text"
    t.integer "questionnaire_question_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["questionnaire_question_id"], name: "index_options_on_questionnaire_question_id"
  end

  create_table "plannings", force: :cascade do |t|
    t.boolean "finished"
    t.integer "plan_id"
    t.integer "activity_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "from_day"
    t.date "to_day"
    t.index ["activity_id"], name: "index_plannings_on_activity_id"
    t.index ["plan_id"], name: "index_plannings_on_plan_id"
  end

  create_table "plans", force: :cascade do |t|
    t.string "name"
    t.string "desc"
    t.date "from_day"
    t.date "to_day"
    t.time "notification_hour_coach_def"
    t.time "notification_hour_user_def"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "delivered"
    t.boolean "communicated"
    t.index ["user_id"], name: "index_plans_on_user_id"
  end

  create_table "questionnaire_answers", force: :cascade do |t|
    t.string "text"
    t.integer "invitation_id"
    t.integer "questionnaire_question_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invitation_id"], name: "index_questionnaire_answers_on_invitation_id"
    t.index ["questionnaire_question_id"], name: "index_questionnaire_answers_on_questionnaire_question_id"
  end

  create_table "questionnaire_questions", force: :cascade do |t|
    t.integer "q_type"
    t.string "text"
    t.integer "questionnaire_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["questionnaire_id"], name: "index_questionnaire_questions_on_questionnaire_id"
  end

  create_table "questionnaires", force: :cascade do |t|
    t.string "title"
    t.string "desc"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "initial"
  end

  create_table "questions", force: :cascade do |t|
    t.text "text"
    t.string "q_type"
    t.integer "planning_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["planning_id"], name: "index_questions_on_planning_id"
  end

  create_table "schedules", force: :cascade do |t|
    t.date "date"
    t.time "time"
    t.integer "day"
    t.integer "planning_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["planning_id"], name: "index_schedules_on_planning_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "telegram_id"
    t.string "first_name"
    t.string "last_name"
    t.string "bot_command_data"
    t.string "email"
    t.string "cellphone"
    t.integer "coach_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "state"
    t.integer "fitbit_status", default: 0
    t.string "identity_token"
    t.integer "identity_token_expires_at"
    t.string "access_token"
    t.integer "cluster"
    t.string "profile_img"
    t.string "aasm_state"
    t.integer "age"
    t.string "py_cluster"
    t.index ["coach_user_id"], name: "index_users_on_coach_user_id"
  end

end
