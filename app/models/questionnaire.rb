class Questionnaire < ApplicationRecord
  has_many :invitations, dependent: :destroy
  has_many :questionnaire_questions, dependent: :destroy
end
