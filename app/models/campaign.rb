class Campaign < ApplicationRecord
  has_many :invitations
  has_many :users, :through => :invitations
  has_many :questionnaires, :through => :invitations
  acts_as_taggable
end
