class Notification < ApplicationRecord
  belongs_to :planning
  has_many :feedbacks, dependent: :destroy
end
