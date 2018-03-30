class Invitation < ApplicationRecord
  belongs_to :user
  belongs_to :questionnaire
  has_many :questionnaire_answers, dependent: :destroy
  acts_as_taggable
end
