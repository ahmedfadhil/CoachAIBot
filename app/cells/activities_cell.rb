class ActivitiesCell < Cell::ViewModel
  include Escaped

  def show
    render
  end

  def activities
    model
  end

  def plan_id
    1
  end

  def user_id
    1
  end

  def decode_category(category)
    case category
      when '0'
        'Dieta'
      when '1'
        "Attivita' Fisica"
      when '2'
        'Benessere Mentale'
      when '3'
        'Medicina'
      else
        'Altro'
    end
  end

  def decode_type(a_type)
    case a_type
      when '0'
        'Giornaliera'
      when '1'
        'Settimanale'
      else
        'Mensile'
    end
  end
end
