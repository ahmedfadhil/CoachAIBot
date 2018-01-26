class CreateQuestionnaires < ActiveRecord::Migration[5.1]
  def change
    create_table :questionnaires do |t|
      t.string :title
      t.string :desc
      t.boolean :completed
      t.timestamps
    end
  end
end
