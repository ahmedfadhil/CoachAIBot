class Question < ApplicationRecord
  has_many :answers, dependent: :destroy
  has_many :feedbacks
  belongs_to :activity
end
