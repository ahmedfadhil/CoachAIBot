class Event < ApplicationRecord
  belongs_to :coach_user

	ReminderType = %w(minutes hours days disabled)
	ReminderMultipliers = { "minutes" => 60, "hours" => 60*60, "days" => 60*60*24}

	validates_inclusion_of :reminder_type, in: ReminderType
	#validates :reminder_range, presence: true
	validates_numericality_of :reminder_range, greater_than: 0

  validates :title, presence: true
  attr_accessor :date_range
  # validates_uniqueness_of :title
  def all_day_event?
    self.start == self.start.midnight && self.end == self.end.midnight ? true : false
  end
end
