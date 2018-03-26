class AddAvatarToCoachUsers < ActiveRecord::Migration[5.1]
  def up
    add_attachment :coach_users, :avatar
  end
  
  def down
    remove_attachment :coach_users, :avatar
  end
end
