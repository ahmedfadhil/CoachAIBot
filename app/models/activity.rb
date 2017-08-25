class Activity < ApplicationRecord
  has_many :questions, dependent: :destroy
  has_many :plannings, dependent: :destroy
  has_many :plans, :through => :plannings
end
