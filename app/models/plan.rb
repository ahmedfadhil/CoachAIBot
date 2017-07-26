class Plan < ApplicationRecord
  belongs_to :user
  has_many :associations, dependent: :destroy
end
