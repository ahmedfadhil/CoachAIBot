class Question < ApplicationRecord
  has_many :answers, dependent: :destroy
  has_many :responses, dependent: :destroy
  belongs_to :activity, optional: true
end
