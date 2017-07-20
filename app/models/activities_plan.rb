class ActivitiesPlan < ApplicationRecord
  has_many :plans
  has_many :activities
end
