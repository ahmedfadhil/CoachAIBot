class Activity < ApplicationRecord
  validates_uniqueness_of :name
  validates :desc, presence: true
  validates :category, presence: true
  validates :a_type, presence: true
  validates :n_times, presence: true

  has_many :questions, dependent: :destroy
  has_many :plannings, dependent: :destroy
  has_many :plans, :through => :plannings
end
