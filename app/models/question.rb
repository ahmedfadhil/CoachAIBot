class Question < ApplicationRecord
  has_many :q_schedule
  belongs_to :activity
end
