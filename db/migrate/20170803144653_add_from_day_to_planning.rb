class AddFromDayToPlanning < ActiveRecord::Migration[5.1]
  def change
    add_column :plannings, :from_day, :date
    add_column :plannings, :to_day, :date
  end
end
