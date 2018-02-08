class AddFitbitStuffToUser < ActiveRecord::Migration[5.1]
	def change
		change_table(:users) do |t|
			t.integer :fitbit_status, default: 0 # 0 means disabled
			t.string :identity_token
			t.integer :identity_token_expires_at
			t.string :access_token
		end
	end
end
