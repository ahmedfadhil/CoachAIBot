class UsersPlan < ApplicationRecord
  belongs_to :user
  belongs_to :plan
end
