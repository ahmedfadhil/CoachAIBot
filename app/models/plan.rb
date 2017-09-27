class Plan < ApplicationRecord
  belongs_to :user, optional: true
  has_many :plannings, dependent: :destroy
  has_many :activities, :through => :plannings
end

