class Questionnaire < ApplicationRecord
  has_many :users, :through => :invitations
  has_many :questionnaire_questions
end
