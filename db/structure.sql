CREATE TABLE "schema_migrations" ("version" varchar NOT NULL PRIMARY KEY);
CREATE TABLE "ar_internal_metadata" ("key" varchar NOT NULL PRIMARY KEY, "value" varchar, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE "users" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "telegram_id" varchar, "first_name" varchar, "last_name" varchar, "bot_command_data" jsonb, "email" varchar, "cellphone" varchar, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE "coach_users" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "email" varchar, "first_name" varchar, "last_name" varchar, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE "plans" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar, "desc" varchar, "from_day" date, "to_day" date, "coach_user_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_a53783e656"
FOREIGN KEY ("coach_user_id")
  REFERENCES "coach_users" ("id")
);
CREATE INDEX "index_plans_on_coach_user_id" ON "plans" ("coach_user_id");
CREATE TABLE "plans_users" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "plan_id" integer, "user_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_faea24e56b"
FOREIGN KEY ("plan_id")
  REFERENCES "plans" ("id")
, CONSTRAINT "fk_rails_8b79d14602"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_plans_users_on_plan_id" ON "plans_users" ("plan_id");
CREATE INDEX "index_plans_users_on_user_id" ON "plans_users" ("user_id");
CREATE TABLE "activities" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar, "desc" varchar, "type" varchar, "n_times" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE "plans_activities" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "plan_id" integer, "activity_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_8c0ffd8e64"
FOREIGN KEY ("plan_id")
  REFERENCES "plans" ("id")
, CONSTRAINT "fk_rails_8cedc947e8"
FOREIGN KEY ("activity_id")
  REFERENCES "activities" ("id")
);
CREATE INDEX "index_plans_activities_on_plan_id" ON "plans_activities" ("plan_id");
CREATE INDEX "index_plans_activities_on_activity_id" ON "plans_activities" ("activity_id");
CREATE TABLE "a_schedules" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "date" date, "time" time, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "user_defined" boolean);
CREATE TABLE "activities_a_schedules" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "activity_id" integer, "a_schedule_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, CONSTRAINT "fk_rails_cb78f1e064"
FOREIGN KEY ("activity_id")
  REFERENCES "activities" ("id")
, CONSTRAINT "fk_rails_697c11339a"
FOREIGN KEY ("a_schedule_id")
  REFERENCES "a_schedules" ("id")
);
CREATE INDEX "index_activities_a_schedules_on_activity_id" ON "activities_a_schedules" ("activity_id");
CREATE INDEX "index_activities_a_schedules_on_a_schedule_id" ON "activities_a_schedules" ("a_schedule_id");
CREATE TABLE "q_schedules" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "date" date, "time" time, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "open" String, "completness" boolean, "range" integer, "user_defined" boolean);
CREATE TABLE "questions" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "text" text, "open" boolean, "completness" boolean, "range" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
INSERT INTO "schema_migrations" (version) VALUES
('20170711085623'),
('20170711085753'),
('20170711114026'),
('20170711120130'),
('20170711120649'),
('20170711120733'),
('20170711120937'),
('20170711121029'),
('20170711121902'),
('20170711122142'),
('20170711123010'),
('20170711123037'),
('20170711123056'),
('20170711123351'),
('20170711123403');


