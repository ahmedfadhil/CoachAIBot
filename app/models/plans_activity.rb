class PlansActivity < ApplicationRecord
  belongs_to :plan
  belongs_to :activity
end
