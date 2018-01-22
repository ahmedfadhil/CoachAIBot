class CreateQuestionnaireAnswers < ActiveRecord::Migration[5.1]
  def change
    create_table :questionnaire_answers do |t|
      t.string :text
      t.references :invitation, foreign_key: true
      t.references :questionnaire_question, foreign_key: true
      t.timestamps
    end
  end
end
