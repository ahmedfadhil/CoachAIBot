class CreateCommunications < ActiveRecord::Migration[5.1]
  def change
    create_table :communications do |t|
      t.integer :c_type
      t.string :text
      t.time :read_at
      t.references :user, foreign_key: true
      t.references :coach_user, foreign_key: true

      t.timestamps
    end
  end
end
