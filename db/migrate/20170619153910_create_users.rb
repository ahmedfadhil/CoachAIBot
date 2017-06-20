class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :telegram_id
      t.string :first_name
      t.string :last_name

      #t.jsonb :bot_command_data, default: {}
      # This is the state of the user
      t.column :bot_command_data, :jsonb #edited

      t.timestamps null: false
    end
  end
end
