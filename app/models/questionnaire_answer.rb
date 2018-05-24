class QuestionnaireAnswer < ApplicationRecord
  belongs_to :invitation
  belongs_to :questionnaire_question



end
