class Activity < ApplicationRecord
  has_many :question, dependent: :destroy
  has_many :associations, dependent: :destroy
end
