class Event < ApplicationRecord
  belongs_to :coach_user
  
  
  validates :title, presence: true
  attr_accessor :date_range
  # validates_uniqueness_of :title
  def all_day_event?
    self.start == self.start.midnight && self.end == self.end.midnight ? true : false
  end
end
