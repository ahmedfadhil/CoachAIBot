class PlanChecker
  def init
    puts 'Checking Plans...'
  end

  def check_and_notify
    plans = Plan.where('delivered = ? AND (communicated is ? OR communicated = ?)', 1, nil, false)
    plans.find_each do |plan|
      if plan.has_period_exceeded? && plan.has_missing_feedback?
        communicate_missing_feedback plan
        Notifier.new.notify_plan_missing_feedback(plan)
      elsif plan.has_period_exceeded?
        communicate_plan_finished plan
        Notifier.new.notify_plan_finished(plan)
      end
    end
  end

  private

  def communicate_missing_feedback(plan)
    communication = Communication.new(:c_type => 0, :text => plan_has_missing_feedback_text(plan), :coach_user_id => plan.user.coach_user.id, :user_id => plan.user.id)
    save_communication(communication, plan)
  end

  def communicate_plan_finished plan
    communication = Communication.new(:c_type => 0, :text => plan_finished_text(plan), :coach_user_id => plan.user.coach_user.id, :user_id => plan.user.id)
    save_communication(communication, plan)
  end

  def plan_has_missing_feedback_text(plan)
    "Il paziente #{plan.user.first_name} #{plan.user.last_name} ha ecceduto il periodo per il piano #{plan.name} ma non ha fornito tutto il feedback riguardante le attivita' che aveva da fare."
  end

  def plan_finished_text(plan)
    "Il paziente #{plan.user.first_name} #{plan.user.last_name} ha portato a termine il piano #{plan.name}. Guarda il suo resoconto per capire come sono andate le sue attivita'."
  end

  def save_communication(communication, plan)
    plan.communicated = true
    plan.save!
    communication.save!
  end

end