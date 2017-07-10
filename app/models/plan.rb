class Plan < ApplicationRecord
  has_and_belongs_to_many :users
  belongs_to :coach_user
end
