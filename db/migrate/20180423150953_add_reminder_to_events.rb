class AddReminderToEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :reminder_type, :string
    add_column :events, :reminder_range, :integer
  end
end
