require 'date'

module PlanningsHelper
  def setup_planning(planning)
    unless planning.schedules.any?
      planning.activity.n_times.times do
        planning.schedules.build
      end
    end
    planning
  end

  def time_format(datetime)
    datetime.strftime('%H:%M') unless datetime.blank?
  end

  def date_format(datetime)
    datetime.strftime('%m/%d/%Y') unless datetime.blank?
  end


  module DateTimeMixin

    def next_week
      self + (7 - self.wday)
    end

    def next_wday (n)
      n > self.wday ? self + (n - self.wday) : self.next_week.next_day(n)
    end

  end


end
