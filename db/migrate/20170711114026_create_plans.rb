class CreatePlans < ActiveRecord::Migration[5.1]
  def change
    create_table :plans do |t|
      t.string :name
      t.string :desc
      t.date :from_day
      t.date :to_day
      t.time :notification_hour_coach_def
      t.time :notification_hour_user_def
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
