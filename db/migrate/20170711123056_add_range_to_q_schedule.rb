class AddRangeToQSchedule < ActiveRecord::Migration[5.1]
  def change
    add_column :q_schedules, :range, :integer
  end
end
