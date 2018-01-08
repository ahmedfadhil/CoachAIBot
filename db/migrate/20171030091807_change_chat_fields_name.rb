class ChangeChatFieldsName < ActiveRecord::Migration[5.1]
  def change
    rename_column :chats, :coach_user_id_id, :coach_user_id
    rename_column :chats, :user_id_id, :user_id
  end
end
