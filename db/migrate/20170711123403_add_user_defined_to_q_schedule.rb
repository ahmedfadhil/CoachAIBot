class AddUserDefinedToQSchedule < ActiveRecord::Migration[5.1]
  def change
    add_column :q_schedules, :user_defined, :boolean
  end
end
