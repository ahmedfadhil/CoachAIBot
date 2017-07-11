class AddOpenToQSchedule < ActiveRecord::Migration[5.1]
  def change
    add_column :q_schedules, :open, :String
  end
end
