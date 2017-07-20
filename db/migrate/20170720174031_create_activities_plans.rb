class CreateActivitiesPlans < ActiveRecord::Migration[5.1]
  def change
    create_table :activities_plans do |t|
      t.references :activity, foreign_key: true
      t.references :plan, foreign_key: true

      t.timestamps
    end
  end
end
