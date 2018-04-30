class WearableCell < Cell::ViewModel
  def card
    render
  end
  
  def title
    model.first_name + " " + model.last_name
  end
  
  
  def profile_image
    ChartDataBinder.new.profile_image_path(model)
  end
  
  def status
    if model.fitbit_disabled?
      css_class = "list-group-item list-group-item-danger"
      content_tag :li, "Integrazione disabilitata", class: css_class
    elsif model.fitbit_invited?
      css_class = "list-group-item list-group-item-warning"
      content_tag :li, "Invito inviato", class: css_class
    else # fitbit_enabled
      css_class = "list-group-item list-group-item-success"
      content_tag :li, "Integrazione abilitata", class: css_class
    end
  end
  
  def show_button
    if model.fitbit_enabled? && model.daily_logs.where("created_at >= ?", Time.zone.now.beginning_of_day).any?
      link_to "Mostra", show_wearable_path(model), class: 'card-link btn-sm'
    else
      link_to "Mostra", show_wearable_path(model), class: 'card-link btn-sm fitbit_user_disabled'
    end
  end
  
  def edit_button
    link_to "Integra", edit_wearable_path(model), class: 'btn btn-warning btn-xs'
  end
  
  def objectives_button
    link_to "Obiettivi", user_objectives_path(model), class: 'btn btn-info btn-xs'
  end
  
  def fitbit_questionnaire_response
    find_questionnaire_response("Registrazione Iniziale", "Sei in possesso di un dispositivo indossabile FITBIT?") == "si"
  end
  
  def find_questionnaire_response(title, question)
    model.invitations.find {|e| e.questionnaire.title == title}&.questionnaire_answers&.find {|e| e.questionnaire_question.text == question}&.text
  end
end
