class Invitation < ApplicationRecord
  belongs_to :user
  belongs_to :questionnaire
  has_many :questionnaire_answers
end
