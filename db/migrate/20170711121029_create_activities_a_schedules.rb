class CreateActivitiesASchedules < ActiveRecord::Migration[5.1]
  def change
    create_table :activities_a_schedules do |t|
      t.references :activity, foreign_key: true
      t.references :a_schedule, foreign_key: true

      t.timestamps
    end
  end
end
