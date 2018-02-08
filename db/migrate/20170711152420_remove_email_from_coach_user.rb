class RemoveEmailFromCoachUser < ActiveRecord::Migration[5.1]
  def change
    remove_column :coach_users, :email, :string
  end
end
