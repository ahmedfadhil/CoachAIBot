class MigrateObjectiveLogType < ActiveRecord::Migration[5.1]
  def change
		change_column :objective_logs, :distance, :decimal
  end
end
