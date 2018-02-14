class CreateBotCommands < ActiveRecord::Migration[5.1]
  def change
    create_table :bot_commands do |t|
      t.string :data
      t.references :user, foreign_key: true
      t.timestamp
    end
  end
end
