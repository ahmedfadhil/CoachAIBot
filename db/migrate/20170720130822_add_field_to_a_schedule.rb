class AddFieldToASchedule < ActiveRecord::Migration[5.1]
  def change
    add_column :a_schedules, :day, :integer
  end
end
