class ASchedule < ApplicationRecord
  has_and_belongs_to_many :activity

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
    end
  end
end
