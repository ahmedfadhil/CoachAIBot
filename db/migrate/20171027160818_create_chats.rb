class CreateChats < ActiveRecord::Migration[5.1]
  def change
    create_table :chats do |t|
      t.references :coach_user, foreign_key: true
      t.references :user, foreign_key: true
      t.string :text
      t.boolean :direction

      t.timestamps
    end
  end
end
