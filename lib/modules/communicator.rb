# communicates relevant information to the coach and when needed also to the patient
require "#{Rails.root}/lib/modules/notifier"

class Communicator
  #Communication types const
  PLAN_FINISHED, PROFILING_DONE, USER_CRITICAL, NEW_MESSAGE = 0, 1, 2, 3

  def init
  end

  def communicate_new_message(user)
    communication = Communication.new(:c_type => NEW_MESSAGE, :text => new_message_text(user), :coach_user_id => user.coach_user.id, :user_id => user.id)
    communication.save!
  end

  def communicate_user_critical(user)
    communication = Communication.new(:c_type => USER_CRITICAL, :text => user_critical_text(user), :coach_user_id => user.coach_user.id, :user_id => user.id)
    communication.save!
  end

  def communicate_profiling_finished(user)
    communication = Communication.new(:c_type => PROFILING_DONE, :text => profiling_finished_text(user), :coach_user_id => user.coach_user.id, :user_id => user.id)
    communication.save!
  end

  def check_plans
    plans = Plan.where('delivered = ? AND (communicated is ? OR communicated = ?)', 1, nil, false)
    plans.find_each do |plan|
      if plan.has_period_exceeded? && plan.has_missing_feedback?
        communicate_missing_feedback plan
        Notifier.new.notify_plan_missing_feedback(plan)
      #elsif plan.has_period_exceeded?
        #communicate_plan_finished plan
        #Notifier.new.notify_plan_finished(plan)
      elsif plan.is_finished?
        plan.delivered = 4
        plan.save!
        communicate_plan_finished plan
        Notifier.new.notify_plan_finished(plan)
      end
    end
  end

  private

  def new_message_text(user)
    "Nuovo messaggio da #{user.first_name} #{user.last_name}. Controlla la sua chat."
  end

  def user_critical_text(user)
    "ATTENZIONE! La situazione del paziente #{user.first_name} #{user.last_name} sta diventando critica. Controlla il suo progresso!"
  end

  def profiling_finished_text(user)
    "Profilazione fatta da parte di #{user.first_name} #{user.last_name}. Controlla le informazioni che sono state raccolte."
  end

  def communicate_missing_feedback(plan)
    communication = Communication.new(:c_type => PLAN_FINISHED, :text => plan_has_missing_feedback_text(plan), :coach_user_id => plan.user.coach_user.id, :user_id => plan.user.id)
    save_communication(communication, plan)
  end

  def communicate_plan_finished plan
    communication = Communication.new(:c_type => PLAN_FINISHED, :text => plan_finished_text(plan), :coach_user_id => plan.user.coach_user.id, :user_id => plan.user.id)
    save_communication(communication, plan)
  end

  def plan_has_missing_feedback_text(plan)
    "Il paziente #{plan.user.first_name} #{plan.user.last_name} ha ecceduto il periodo per il piano #{plan.name} ma non ha fornito tutto il feedback riguardante le attività che aveva da fare."
  end

  def plan_finished_text(plan)
    "Il paziente #{plan.user.first_name} #{plan.user.last_name} ha portato a termine il piano #{plan.name}. Guarda il suo resoconto per capire come sono andate le sue attività."
  end

  def save_communication(communication, plan)
    plan.communicated = true
    plan.save!
    communication.save!
  end

end