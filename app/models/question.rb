class Question < ApplicationRecord
  has_many :answers, dependent: :destroy
  has_many :feedbacks, dependent: :destroy
  belongs_to :activity, optional: true
end
