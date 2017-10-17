class Schedule < ApplicationRecord
  belongs_to :planning, inverse_of: :schedules
  validate :date_cannot_be_other_than_plan

  def at_least_one_name
    if [self.date, self.time, self.day].reject(&:blank?).size == 0
      errors[:base] << ('Devi inserire almeno un dato per una pianificazione!')
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

  def  date_cannot_be_other_than_plan
    unless self.date.nil?
      if self.date < self.planning.plan.from_day || self.date < self.planning.plan.from_day
        self.planning.errors.add(:schedules, "Pianificazione non inserita")
        self.planning.errors.add(:schedules, "Le pianificazioni per il piano #{self.planning.plan.name} devono essere tra #{self.planning.plan.from_day} e il #{self.planning.plan.to_day}")
      end
    end
  end


end
