class Schedule < ApplicationRecord
  belongs_to :planning, inverse_of: :schedules

  def at_least_one_name
    if [self.date, self.time, self.day].reject(&:blank?).size == 0
      errors[:base] << ('Please choose at least one name - any language will do.')
    end
  end

  def day_of_week (day)
    case day
      when 0
        'Lun'
      when 1
        'Mar'
      when 2
        'Mer'
      when 3
        'Gio'
      when 4
        'Ven'
      when 5
        'Sab'
      when 6
        'Dom'
      else
        'UNKNOWN'
    end
  end

end
