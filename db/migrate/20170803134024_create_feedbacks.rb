class CreateFeedbacks < ActiveRecord::Migration[5.1]
  def change
    create_table :feedbacks do |t|
      t.text :answer
      t.date :date
      t.references :question, foreign_key: true
      t.references :notification, foreign_key: true

      t.timestamps
    end
  end
end
