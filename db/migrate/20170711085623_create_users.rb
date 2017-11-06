class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :telegram_id
      t.string :first_name
      t.string :last_name

      #t.jsonb :bot_command_data, default: {}
      #t.column :bot_command_data, :json
			#t.json :bot_command_data, default: {}
			t.string :bot_command_data

      t.string :email
      t.string :cellphone

      t.references :coach_user, foreign_key: true

      t.timestamps
    end
  end
end
