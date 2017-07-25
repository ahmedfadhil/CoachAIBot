class Plan < ApplicationRecord
  belongs_to :coach_user
  has_and_belongs_to_many :user, dependent: :destroy
  has_and_belongs_to_many :activity, dependent: :destroy
end
