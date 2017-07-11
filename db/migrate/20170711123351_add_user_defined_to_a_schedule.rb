class AddUserDefinedToASchedule < ActiveRecord::Migration[5.1]
  def change
    add_column :a_schedules, :user_defined, :boolean
  end
end
