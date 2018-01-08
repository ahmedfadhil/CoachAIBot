class ChangeReadAtToDatetime < ActiveRecord::Migration[5.1]
  def change
    change_column :communications, :read_at, :datetime
  end
end
