class Option < ApplicationRecord
  belongs_to :questionnaire_question
  validates :text, presence: true
  validates :score, presence: true
end
