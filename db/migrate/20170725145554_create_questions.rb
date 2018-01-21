class CreateQuestions < ActiveRecord::Migration[5.1]
  def change
    create_table :questions do |t|
      t.text :text
      t.string :q_type
      t.references :planning, foreign_key: true

      t.timestamps
    end
  end
end
