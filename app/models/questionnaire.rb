class Questionnaire < ApplicationRecord
  has_many :invitations, dependent: :destroy
  has_many :questionnaire_questions, dependent: :destroy

  validates_uniqueness_of :title, message: "Esiste gia' un questionario con questo nome. Scegli un'atro nome!"
  accepts_nested_attributes_for :questionnaire_questions, allow_destroy: true, :reject_if => lambda { |attributes| attributes[:text].blank? }
end
