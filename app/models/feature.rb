class Feature < ApplicationRecord
  belongs_to :user, optional: true
end
