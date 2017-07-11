class CreatePlansActivities < ActiveRecord::Migration[5.1]
  def change
    create_table :plans_activities do |t|
      t.references :plan, foreign_key: true
      t.references :activity, foreign_key: true

      t.timestamps
    end
  end
end
