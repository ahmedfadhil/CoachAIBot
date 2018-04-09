class CreateWeeklyLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :weekly_logs do |t|
      t.date :start_date
      t.date :end_date
      t.integer :steps
      t.integer :distance
      t.references :objective, foreign_key: true

      t.timestamps
    end
  end
end
