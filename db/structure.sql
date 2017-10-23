CREATE TABLE "schema_migrations" ("version" varchar NOT NULL PRIMARY KEY);
CREATE TABLE "ar_internal_metadata" ("key" varchar NOT NULL PRIMARY KEY, "value" varchar, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE "users" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "telegram_id" varchar, "first_name" varchar, "last_name" varchar, "bot_command_data" jsonb, "email" varchar, "cellphone" varchar, "coach_user_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "state" varchar, "cluster" varchar, CONSTRAINT "fk_rails_f04ae787c4"
FOREIGN KEY ("coach_user_id")
  REFERENCES "coach_users" ("id")
);
CREATE INDEX "index_users_on_coach_user_id" ON "users" ("coach_user_id");
CREATE TABLE "plans" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar, "desc" varchar, "from_day" date, "to_day" date, "notification_hour_coach_def" time, "notification_hour_user_def" time, "user_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "delivered" integer, CONSTRAINT "fk_rails_45da853770"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_plans_on_user_id" ON "plans" ("user_id");
CREATE TABLE "coach_users" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "first_name" varchar DEFAULT NULL, "last_name" varchar DEFAULT NULL, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "email" varchar DEFAULT '' NOT NULL, "encrypted_password" varchar DEFAULT '' NOT NULL, "reset_password_token" varchar, "reset_password_sent_at" datetime, "remember_created_at" datetime, "sign_in_count" integer DEFAULT 0 NOT NULL, "current_sign_in_at" datetime, "last_sign_in_at" datetime, "current_sign_in_ip" varchar, "last_sign_in_ip" varchar);
CREATE UNIQUE INDEX "index_coach_users_on_email" ON "coach_users" ("email");
CREATE UNIQUE INDEX "index_coach_users_on_reset_password_token" ON "coach_users" ("reset_password_token");
CREATE TABLE "activities" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar DEFAULT NULL, "desc" varchar DEFAULT NULL, "a_type" varchar DEFAULT NULL, "n_times" integer DEFAULT NULL, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "category" varchar DEFAULT NULL);
CREATE TABLE "schedules" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "date" date, "time" time, "day" integer, "planning_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_b56518c6f6"
FOREIGN KEY ("planning_id")
  REFERENCES "plannings" ("id")
);
CREATE INDEX "index_schedules_on_planning_id" ON "schedules" ("planning_id");
CREATE TABLE "questions" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "text" text, "q_type" varchar, "activity_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_553dbb8113"
FOREIGN KEY ("activity_id")
  REFERENCES "activities" ("id")
);
CREATE INDEX "index_questions_on_activity_id" ON "questions" ("activity_id");
CREATE TABLE "answers" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "text" text, "question_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_3d5ed4418f"
FOREIGN KEY ("question_id")
  REFERENCES "questions" ("id")
);
CREATE INDEX "index_answers_on_question_id" ON "answers" ("question_id");
CREATE TABLE "plannings" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "finished" boolean, "plan_id" integer, "activity_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "from_day" date, "to_day" date, CONSTRAINT "fk_rails_84268e3969"
FOREIGN KEY ("plan_id")
  REFERENCES "plans" ("id")
, CONSTRAINT "fk_rails_11221890a4"
FOREIGN KEY ("activity_id")
  REFERENCES "activities" ("id")
);
CREATE INDEX "index_plannings_on_plan_id" ON "plannings" ("plan_id");
CREATE INDEX "index_plannings_on_activity_id" ON "plannings" ("activity_id");
CREATE TABLE "notifications" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "default" boolean, "date" date, "time" time, "sent" boolean, "planning_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "n_type" varchar, "done" integer, CONSTRAINT "fk_rails_49e8ec0964"
FOREIGN KEY ("planning_id")
  REFERENCES "plannings" ("id")
);
CREATE INDEX "index_notifications_on_planning_id" ON "notifications" ("planning_id");
CREATE TABLE "feedbacks" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "answer" text, "date" date, "question_id" integer, "notification_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_76b25c55f1"
FOREIGN KEY ("question_id")
  REFERENCES "questions" ("id")
, CONSTRAINT "fk_rails_570988099c"
FOREIGN KEY ("notification_id")
  REFERENCES "notifications" ("id")
);
CREATE INDEX "index_feedbacks_on_question_id" ON "feedbacks" ("question_id");
CREATE INDEX "index_feedbacks_on_notification_id" ON "feedbacks" ("notification_id");
CREATE TABLE "features" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "physical" integer, "health" integer, "mental" integer, "coping" integer, "physical_sport" varchar, "physical_sport_frequency" varchar, "physical_sport_intensity" varchar, "physical_goal" varchar, "health_personality" varchar, "health_wellbeing_meaning" varchar, "health_nutritional_habits" varchar, "health_drinking_water" varchar, "health_vegetables_eaten" varchar, "health_energy_level" varchar, "coping_stress" varchar, "coping_sleep_hours" varchar, "coping_energy_level" varchar, "mental_nervous" varchar, "mental_depressed" varchar, "mental_effort" varchar, "user_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_9e549256a3"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_features_on_user_id" ON "features" ("user_id");
CREATE TABLE "crono_jobs" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "job_id" varchar NOT NULL, "log" text(1073741823), "last_performed_at" datetime, "healthy" boolean, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE UNIQUE INDEX "index_crono_jobs_on_job_id" ON "crono_jobs" ("job_id");
INSERT INTO "schema_migrations" (version) VALUES
('20170711085623'),
('20170711085753'),
('20170711114026'),
('20170711120649'),
('20170711152420'),
('20170711152815'),
('20170718115019'),
('20170720095130'),
('20170725145453'),
('20170725145554'),
('20170725145619'),
('20170726083535'),
('20170726134458'),
('20170803133818'),
('20170803134024'),
('20170803144653'),
('20170809081733'),
('20170811102128'),
('20170823093058'),
('20170914121008'),
('20171019085512'),
('20171023151145');


