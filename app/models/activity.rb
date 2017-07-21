class Activity < ApplicationRecord
  has_and_belongs_to_many :plan, dependent: :destroy
  has_and_belongs_to_many :a_schedule, dependent: :destroy
  has_many :question, dependent: :destroy
end
