class Planning < ApplicationRecord
  belongs_to :plan
  belongs_to :activity
  has_many :schedules, dependent: :destroy
end
