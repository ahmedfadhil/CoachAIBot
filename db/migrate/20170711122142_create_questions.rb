class CreateQuestions < ActiveRecord::Migration[5.1]
  def change
    create_table :questions do |t|
      t.text :text
      t.boolean :open
      t.boolean :completness
      t.integer :range

      t.timestamps
    end
  end
end
