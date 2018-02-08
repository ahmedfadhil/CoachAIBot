class UserPlansCell < Cell::ViewModel
  def show
    render
  end

  def sub_menu
    render
  end

  def user
    model
  end

  def model_name
    model[:name]
  end

  def plans
    options[:plans]
  end

  # returns the class to apply to the plan in function of his state
  def is_delivered?(plan)
    case plan.delivered
      when 0
        'mdl-card__titleNew'
      when 1
        'mdl-card__titleDelivered'
      else
        'mdl-card__titleSuspended'
    end
  end

  def time_format(time)
    time.strftime('%H:%M') unless time.blank? || time.nil?
  end

  def date_format(datetime)
    datetime.strftime('%m/%d/%Y') unless datetime.blank? || datetime.nil?
  end

end
