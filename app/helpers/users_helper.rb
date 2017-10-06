module UsersHelper

  def week_and_order(by, plan, planning, notification)
    # looping through months
    date = notification.date
    from = plan.from_day
    to = plan.to_day
    interval = by
    start = from
    week_number = 1
    while start < to
      stop  = start.send("end_of_#{interval}")
      if stop > to
        stop = to
      end

      # create default notifications based on period and number of times to do an activity
      interval_start = Date.parse(start.inspect)
      interval_end = Date.parse(stop.inspect)
      if interval_start<=date && interval_end>=date
        return week_number, Notification.where('planning_id = (?) AND date >= (?) AND date <= (?)', planning.id, interval_start, interval_end).index(notification)+1
      end

      start = stop.send("beginning_of_#{interval}")
      start += 1.send(interval)
      week_number = week_number + 1
    end
  end

  def time_format(datetime)
    datetime.strftime('%H:%M') unless datetime.blank?
  end

  def delivered?(plan)
    case plan.delivered
      when 0
        'mdl-card__title'
      when 1
        'mdl-card__title2'
      when 2
        'mdl-card__title3'
      else
        'mdl-card__title4'
    end
  end

  def remove_first_char(string)
    string[0] = ''
    string.downcase.tr('_', ' ')
  end

  def ita_category(cat)
    case cat
      when '0', 0
        'Dieta'
      when '1', 1
        'Attivita\' Fisica'
      when '2', 2
        'Benessere Mentale'
      when '3', 3
        'Medicina'
      else
        'Altro'
    end
  end

  def ita_a_type(a_type)
    case a_type
      when 0, '0'
        'Giorno'
      when 1, '1'
        'Settimana'
      else
        'Mese'
    end
  end

  def ita_schedule(schedule)
    ita_text = ''
    unless schedule.date.nil?
      ita_text += "Data: #{schedule.date.strftime('%d.%m.%Y')} "
    end
    unless schedule.day.nil?
      ita_text += "Giorno: #{ita_day(schedule.day)} "
    end
    unless schedule.time.nil?
      ita_text += "Ora: #{schedule.time.strftime('%H:%M')} "
    end
    ita_text
  end

  def ita_day(day)
    case day
      when 0
        'Lunedi'
      when 1
        'Martedi'
      when 2
        'Mercoledi'
      when 3
        'Giovedi'
      when 4
        'Venerdi'
      when 5
        'Sabato'
      else
        'Domenica'
    end
  end

  def pdf_activity_img(category)
    case category
      when '0'
        'rsz_diet.png'
      when '1'
        'rsz_doc-bot.png'
      when '2'
        'rsz_mental.png'
      when '3'
        'rsz_medicine.png'
      else
        'rsz_other.png'
    end
  end

end
