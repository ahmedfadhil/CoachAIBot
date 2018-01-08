class CreateNotifications < ActiveRecord::Migration[5.1]
  def change
    create_table :notifications do |t|
      t.boolean :default
      t.date :date
      t.time :time
      t.boolean :sent
      t.references :planning, foreign_key: true

      t.timestamps
    end
  end
end
