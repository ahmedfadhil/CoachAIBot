class Plan < ApplicationRecord
  belongs_to :coach_user
  has_and_belongs_to_many :user
  has_and_belongs_to_many :activity
end
