CREATE TABLE "schema_migrations" ("version" varchar NOT NULL PRIMARY KEY);
CREATE TABLE "ar_internal_metadata" ("key" varchar NOT NULL PRIMARY KEY, "value" varchar, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE "users" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "telegram_id" varchar, "first_name" varchar, "last_name" varchar, "bot_command_data" jsonb, "email" varchar, "cellphone" varchar, "coach_user_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "state" varchar, CONSTRAINT "fk_rails_f04ae787c4"
FOREIGN KEY ("coach_user_id")
  REFERENCES "coach_users" ("id")
);
CREATE INDEX "index_users_on_coach_user_id" ON "users" ("coach_user_id");
CREATE TABLE "plans" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar, "desc" varchar, "from_day" date, "to_day" date, "notification_hour_coach_def" time, "notification_hour_user_def" time, "user_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_45da853770"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_plans_on_user_id" ON "plans" ("user_id");
CREATE TABLE "coach_users" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "first_name" varchar DEFAULT NULL, "last_name" varchar DEFAULT NULL, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "email" varchar DEFAULT '' NOT NULL, "encrypted_password" varchar DEFAULT '' NOT NULL, "reset_password_token" varchar, "reset_password_sent_at" datetime, "remember_created_at" datetime, "sign_in_count" integer DEFAULT 0 NOT NULL, "current_sign_in_at" datetime, "last_sign_in_at" datetime, "current_sign_in_ip" varchar, "last_sign_in_ip" varchar);
CREATE UNIQUE INDEX "index_coach_users_on_email" ON "coach_users" ("email");
CREATE UNIQUE INDEX "index_coach_users_on_reset_password_token" ON "coach_users" ("reset_password_token");
CREATE TABLE "activities" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar DEFAULT NULL, "desc" varchar DEFAULT NULL, "a_type" varchar DEFAULT NULL, "n_times" integer DEFAULT NULL, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "category" varchar DEFAULT NULL);
CREATE TABLE "features" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "health" boolean, "physical" boolean, "mental" boolean, "user_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_9e549256a3"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_features_on_user_id" ON "features" ("user_id");
CREATE TABLE "associations" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "finished" boolean, "plan_id" integer, "activity_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_05d02cb53f"
FOREIGN KEY ("plan_id")
  REFERENCES "plans" ("id")
, CONSTRAINT "fk_rails_e4418d7c25"
FOREIGN KEY ("activity_id")
  REFERENCES "activities" ("id")
);
CREATE INDEX "index_associations_on_plan_id" ON "associations" ("plan_id");
CREATE INDEX "index_associations_on_activity_id" ON "associations" ("activity_id");
CREATE TABLE "schedules" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "date" date, "time" time, "day" integer, "association_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_da30061917"
FOREIGN KEY ("association_id")
  REFERENCES "associations" ("id")
);
CREATE INDEX "index_schedules_on_association_id" ON "schedules" ("association_id");
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
CREATE TABLE "responses" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "answer" text, "date" date, "user_id" integer, "question_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_2bd9a0753e"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_325af149a3"
FOREIGN KEY ("question_id")
  REFERENCES "questions" ("id")
);
CREATE INDEX "index_responses_on_user_id" ON "responses" ("user_id");
CREATE INDEX "index_responses_on_question_id" ON "responses" ("question_id");
INSERT INTO "schema_migrations" (version) VALUES
('20170711085623'),
('20170711085753'),
('20170711114026'),
('20170711120649'),
('20170711152420'),
('20170711152815'),
('20170718115019'),
('20170720095130'),
('20170725145037'),
('20170725145419'),
('20170725145453'),
('20170725145554'),
('20170725145619'),
('20170725145701'),
('20170726083535');


