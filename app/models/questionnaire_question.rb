class QuestionnaireQuestion < ApplicationRecord
  belongs_to :questionnaire
  has_many :questionnaire_answers
  has_many :options, dependent: :destroy
  enum q_type: [:multiple_choice, :yes_no, :numerical] # just numbers inside the db
  accepts_nested_attributes_for :options, allow_destroy: true, :reject_if => lambda { |attributes| attributes[:text].blank? }
end
