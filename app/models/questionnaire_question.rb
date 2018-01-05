class QuestionnaireQuestion < ApplicationRecord
  belongs_to :questionnaire
  has_many :options
end
