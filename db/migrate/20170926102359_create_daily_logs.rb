class CreateDailyLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :daily_logs do |t|
      t.references :user, foreign_key: true
      t.float :distance
      t.integer :calories
      t.integer :steps
      t.integer :sleep
      t.date :date

      t.timestamps
    end
  end
end
