class Plan < ApplicationRecord
  belongs_to :user, optional: true
  has_many :plannings, dependent: :destroy
end
