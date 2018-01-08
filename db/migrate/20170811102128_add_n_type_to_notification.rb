class AddNTypeToNotification < ActiveRecord::Migration[5.1]
  def change
    add_column :notifications, :n_type, :string
  end
end
