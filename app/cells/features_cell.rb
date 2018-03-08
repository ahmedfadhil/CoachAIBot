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

  def user
    model
  end


  def cluster
    case user.py_cluster
      when 'HIGH'
        'Molto Attivo'
      when 'MEDIUM'
        'Mediamente Attivo'
      else #LOW
        'Poco Attivo'
    end
  end


  def profile_photo_url
    if user.telegram_id.nil?
      default_image
    else
      begin
        solver = ImageSolver.new
        solver.solve(user.telegram_id)
      rescue Exception
        default_image
      end
    end
  end

  def default_image
    'https://i.imgur.com/hur32sb.png'
  end
  
end
