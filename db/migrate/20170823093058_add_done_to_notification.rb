class AddDoneToNotification < ActiveRecord::Migration[5.1]
  def change
    add_column :notifications, :done, :integer
  end
end
