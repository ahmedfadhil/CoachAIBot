module UsersHelper

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

end
