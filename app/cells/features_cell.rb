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

  def invitation_questionnaire(invitation, question)
    result = invitation.questionnaire_answers.where(questionnaire_question: question).first
    if result
      return result.text
    else
      return "Non trovato"
    end

  end

# <!--ActsAsTaggableOn::Tagging.includes(:tag).where(context: 'deshanatags').map {
# |tagging| { 'id' => tagging.tag_id.to_s, 'name' => tagging.tag.name } }.uniq-->
  def user_score
    # User.last.questionnaire_answers.last.questionnaire_question.options.last.score
    # scoring = user.questionnaire_answers.to_a.map { |e| e.questionnaire_question.options.last.score}
    if scoring
      return scoring
    else
      "Non trovato"
    end
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
    # 'https://i.imgur.com/hur32sb.png'
    'https://i.imgur.com/tX1rzj3.png'
  end

end
