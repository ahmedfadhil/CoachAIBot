class Chat < ApplicationRecord
  belongs_to :coach_user
  belongs_to :user
end
