class Activity < ApplicationRecord
  has_and_belongs_to_many :plan
  has_and_belongs_to_many :a_schedule
  has_many :question
end
