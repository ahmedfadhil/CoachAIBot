class PlanningDescriptionCell < Cell::ViewModel
  def show
    render
  end

  def planning
    model
  end

  def ita_type(activity_type)
    case activity_type
      when 0, '0'
        'Giorno'
      when 1, '1'
        'Settimana'
      else
        'Mese'
    end
  end

  def ita_category(activity_category)
    case activity_category
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

end
