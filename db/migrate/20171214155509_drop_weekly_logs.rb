class DropWeeklyLogs < ActiveRecord::Migration[5.1]
  def change
		drop_table :weekly_logs do
			#void
		end
		create_table :objective_logs do |t|
			t.integer :steps
			t.integer :distance
			t.references :objective, foreign_key: true

			t.timestamps
		end
  end
end
