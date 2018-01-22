class CreateQuestionnaireQuestions < ActiveRecord::Migration[5.1]
  def change
    create_table :questionnaire_questions do |t|
      t.integer :q_type
      t.string :text
      t.references :questionnaire, foreign_key: true
      t.timestamps
    end
  end
end
