class FeaturesCell < Cell::ViewModel
  def show
    render
  end

  def no_features_card
    render
  end

  def features_card
    render
  end

  def mental
    render
  end

  def health
    render
  end

  def coping
    render
  end

  def physical
    render
  end

  def lateral_info
    render
  end

  def features
    model
  end

  def user
    features.user
  end

  def no_features_collected
    (features.health == 0) && (features.physical == 0) && (features.coping == 0) && (features.mental == 0)
  end

  def remove_first_char(string)
    string[0] = ''
    string.downcase.tr('_', ' ')
  end

  def decode_work_physical_activity(code)
    case code
      when 0, '0'
        'quasi sempre seduto'
      when 1, '1'
        'moderato, sta sia seduto che in movimento'
      else #2
        'quasi sempre in movimento'
    end
  end

  def decode_foot_bicycle(code)
    case code
      when 0, '0'
        'quasi mai'
      when 1, '1'
        'a volte'
      else #2
        'quasi sempre'
    end
  end

  def decode_stress(code)
    case code
      when 0, '0'
        'basso'
      when 1, '1'
        'medio'
      else #2
        'alto'
    end
  end
end
