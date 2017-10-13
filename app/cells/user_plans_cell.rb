class UserPlansCell < Cell::ViewModel
  def show
    render
  end

  def user
    model
  end

  def model_name
    model[:name]
  end

  # returns the class to apply to the plan in function of his state
  def is_delivered?(plan)
    case plan.delivered
      when 0
        'mdl-card__titleNew'
      when 1
        'mdl-card__titleDelivered'
      when 2
        'mdl-card__titleSuspended'
      else
        'mdl-card__titleStopped' # or finished
    end
  end

  def time_format(datetime)
    datetime.strftime('%H:%M') unless datetime.blank?
  end

  def date_format(datetime)
    datetime.strftime('%m/%d/%Y') unless datetime.blank?
  end

end
