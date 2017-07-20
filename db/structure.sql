CREATE TABLE "schema_migrations" ("version" varchar NOT NULL PRIMARY KEY);
CREATE TABLE "ar_internal_metadata" ("key" varchar NOT NULL PRIMARY KEY, "value" varchar, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE "users" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "telegram_id" varchar, "first_name" varchar, "last_name" varchar, "bot_command_data" jsonb, "email" varchar, "cellphone" varchar, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE "plans" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar, "desc" varchar, "from_day" date, "to_day" date, "coach_user_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_a53783e656"
FOREIGN KEY ("coach_user_id")
  REFERENCES "coach_users" ("id")
);
CREATE INDEX "index_plans_on_coach_user_id" ON "plans" ("coach_user_id");
CREATE TABLE "a_schedules" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "date" date, "time" time, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "user_defined" boolean, "day" integer);
CREATE TABLE "q_schedules" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "date" date, "time" time, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "open" String, "completness" boolean, "range" integer, "user_defined" boolean);
CREATE TABLE "questions" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "text" text, "open" boolean, "completness" boolean, "range" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE "coach_users" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "first_name" varchar DEFAULT NULL, "last_name" varchar DEFAULT NULL, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "email" varchar DEFAULT '' NOT NULL, "encrypted_password" varchar DEFAULT '' NOT NULL, "reset_password_token" varchar, "reset_password_sent_at" datetime, "remember_created_at" datetime, "sign_in_count" integer DEFAULT 0 NOT NULL, "current_sign_in_at" datetime, "last_sign_in_at" datetime, "current_sign_in_ip" varchar, "last_sign_in_ip" varchar);
CREATE UNIQUE INDEX "index_coach_users_on_email" ON "coach_users" ("email");
CREATE UNIQUE INDEX "index_coach_users_on_reset_password_token" ON "coach_users" ("reset_password_token");
CREATE TABLE "activities" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar DEFAULT NULL, "desc" varchar DEFAULT NULL, "a_type" varchar DEFAULT NULL, "n_times" integer DEFAULT NULL, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "category" varchar DEFAULT NULL);
CREATE TABLE "activities_plans" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "activity_id" integer, "plan_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_050b3bdc49"
FOREIGN KEY ("activity_id")
  REFERENCES "activities" ("id")
, CONSTRAINT "fk_rails_f23ae0617c"
FOREIGN KEY ("plan_id")
  REFERENCES "plans" ("id")
);
CREATE INDEX "index_activities_plans_on_activity_id" ON "activities_plans" ("activity_id");
CREATE INDEX "index_activities_plans_on_plan_id" ON "activities_plans" ("plan_id");
CREATE TABLE "plans_users" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "plan_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_8b79d14602"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_faea24e56b"
FOREIGN KEY ("plan_id")
  REFERENCES "plans" ("id")
);
CREATE INDEX "index_plans_users_on_user_id" ON "plans_users" ("user_id");
CREATE INDEX "index_plans_users_on_plan_id" ON "plans_users" ("plan_id");
CREATE TABLE "a_schedules_activities" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "a_schedule_id" integer, "activity_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_cbe39dd971"
FOREIGN KEY ("a_schedule_id")
  REFERENCES "a_schedules" ("id")
, CONSTRAINT "fk_rails_1090beeebf"
FOREIGN KEY ("activity_id")
  REFERENCES "activities" ("id")
);
CREATE INDEX "index_a_schedules_activities_on_a_schedule_id" ON "a_schedules_activities" ("a_schedule_id");
CREATE INDEX "index_a_schedules_activities_on_activity_id" ON "a_schedules_activities" ("activity_id");
INSERT INTO "schema_migrations" (version) VALUES
('20170711085623'),
('20170711085753'),
('20170711114026'),
('20170711120649'),
('20170711120937'),
('20170711121902'),
('20170711122142'),
('20170711123010'),
('20170711123037'),
('20170711123056'),
('20170711123351'),
('20170711123403'),
('20170711152420'),
('20170711152815'),
('20170718115019'),
('20170720095130'),
('20170720130822'),
('20170720174031'),
('20170720211946'),
('20170720212243');


