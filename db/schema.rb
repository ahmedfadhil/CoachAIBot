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

ActiveRecord::Schema.define(version: 20180330092727) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.bigint "question_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_answers_on_question_id"
  end

  create_table "bot_commands", force: :cascade do |t|
    t.string "data"
    t.bigint "user_id"
    t.index ["user_id"], name: "index_bot_commands_on_user_id"
  end

  create_table "chats", force: :cascade do |t|
    t.bigint "coach_user_id"
    t.bigint "user_id"
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
    t.string "avatar_file_name"
    t.string "avatar_content_type"
    t.integer "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.index ["email"], name: "index_coach_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_coach_users_on_reset_password_token", unique: true
  end

  create_table "communications", force: :cascade do |t|
    t.integer "c_type"
    t.string "text"
    t.datetime "read_at"
    t.bigint "user_id"
    t.bigint "coach_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["coach_user_id"], name: "index_communications_on_coach_user_id"
    t.index ["user_id"], name: "index_communications_on_user_id"
  end

  create_table "crono_jobs", force: :cascade do |t|
    t.string "job_id", null: false
    t.text "log"
    t.datetime "last_performed_at"
    t.boolean "healthy"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id"], name: "index_crono_jobs_on_job_id", unique: true
  end

  create_table "daily_logs", force: :cascade do |t|
    t.bigint "user_id"
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
    t.bigint "question_id"
    t.bigint "notification_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notification_id"], name: "index_feedbacks_on_notification_id"
    t.index ["question_id"], name: "index_feedbacks_on_question_id"
  end

  create_table "invitations", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "questionnaire_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "completed"
    t.string "campaign"
    t.index ["questionnaire_id"], name: "index_invitations_on_questionnaire_id"
    t.index ["user_id"], name: "index_invitations_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.boolean "default"
    t.date "date"
    t.time "time"
    t.boolean "sent"
    t.bigint "planning_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "n_type"
    t.integer "done"
    t.index ["planning_id"], name: "index_notifications_on_planning_id"
  end

  create_table "objective_logs", force: :cascade do |t|
    t.integer "steps"
    t.decimal "distance"
    t.bigint "objective_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["objective_id"], name: "index_objective_logs_on_objective_id"
  end

  create_table "objectives", force: :cascade do |t|
    t.bigint "user_id"
    t.integer "scheduler"
    t.integer "activity"
    t.integer "steps"
    t.integer "distance"
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "fitbit_integration"
    t.index ["user_id"], name: "index_objectives_on_user_id"
  end

  create_table "options", force: :cascade do |t|
    t.string "text"
    t.bigint "questionnaire_question_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "score"
    t.index ["questionnaire_question_id"], name: "index_options_on_questionnaire_question_id"
  end

  create_table "plannings", force: :cascade do |t|
    t.boolean "finished"
    t.bigint "plan_id"
    t.bigint "activity_id"
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
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "delivered"
    t.boolean "communicated"
    t.index ["user_id"], name: "index_plans_on_user_id"
  end

  create_table "questionnaire_answers", force: :cascade do |t|
    t.string "text"
    t.bigint "invitation_id"
    t.bigint "questionnaire_question_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invitation_id"], name: "index_questionnaire_answers_on_invitation_id"
    t.index ["questionnaire_question_id"], name: "index_questionnaire_answers_on_questionnaire_question_id"
  end

  create_table "questionnaire_questions", force: :cascade do |t|
    t.integer "q_type"
    t.string "text"
    t.bigint "questionnaire_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["questionnaire_id"], name: "index_questionnaire_questions_on_questionnaire_id"
  end

  create_table "questionnaires", force: :cascade do |t|
    t.string "title"
    t.string "desc"
    t.boolean "completed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "initial"
  end

  create_table "questions", force: :cascade do |t|
    t.text "text"
    t.string "q_type"
    t.bigint "planning_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["planning_id"], name: "index_questions_on_planning_id"
  end

  create_table "schedules", force: :cascade do |t|
    t.date "date"
    t.time "time"
    t.integer "day"
    t.bigint "planning_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["planning_id"], name: "index_schedules_on_planning_id"
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "taggable_id"
    t.string "tagger_type"
    t.integer "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at"
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "telegram_id"
    t.string "first_name"
    t.string "last_name"
    t.string "bot_command_data"
    t.string "email"
    t.string "cellphone"
    t.bigint "coach_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "state"
    t.integer "fitbit_status", default: 0
    t.string "identity_token"
    t.integer "identity_token_expires_at"
    t.string "access_token"
    t.integer "cluster"
    t.string "aasm_state"
    t.integer "age"
    t.string "py_cluster"
    t.string "patient_objective"
    t.string "gender"
    t.decimal "height"
    t.decimal "weight"
    t.string "blood_type"
    t.index ["coach_user_id"], name: "index_users_on_coach_user_id"
  end

  add_foreign_key "answers", "questions"
  add_foreign_key "bot_commands", "users"
  add_foreign_key "chats", "coach_users"
  add_foreign_key "chats", "users"
  add_foreign_key "communications", "coach_users"
  add_foreign_key "communications", "users"
  add_foreign_key "daily_logs", "users"
  add_foreign_key "feedbacks", "notifications"
  add_foreign_key "feedbacks", "questions"
  add_foreign_key "invitations", "questionnaires"
  add_foreign_key "invitations", "users"
  add_foreign_key "notifications", "plannings"
  add_foreign_key "objective_logs", "objectives"
  add_foreign_key "options", "questionnaire_questions"
  add_foreign_key "plannings", "activities"
  add_foreign_key "plannings", "plans"
  add_foreign_key "plans", "users"
  add_foreign_key "questionnaire_answers", "invitations"
  add_foreign_key "questionnaire_answers", "questionnaire_questions"
  add_foreign_key "questionnaire_questions", "questionnaires"
  add_foreign_key "questions", "plannings"
  add_foreign_key "schedules", "plannings"
  add_foreign_key "users", "coach_users"
end
