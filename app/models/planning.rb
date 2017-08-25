class Planning < ApplicationRecord
  belongs_to :plan
  belongs_to :activity
  has_many :schedules, dependent: :destroy, inverse_of: :planning
  has_many :notifications, dependent: :destroy

  accepts_nested_attributes_for :schedules,
                                :allow_destroy => true,
                                :reject_if     => :all_blank
  end
