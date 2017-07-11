class AddCompletnessToQSchedule < ActiveRecord::Migration[5.1]
  def change
    add_column :q_schedules, :completness, :boolean
  end
end
