require 'telegram/bot'
require './lib/modules/chart_data_binder'

# creates all the notifications for the user, that are reminders
class Notifier
  DIET, PHYSICAL, MENTAL = 0, 1, 2
  REGISTERED = 'REGISTERED'

  def init
    puts 'Ready to notify!'
  end

  def notify_weekly_progress(user)
    if user.state == REGISTERED and user.has_delivered_plans?
      binder = ChartDataBinder.new
      mental_score = binder.score(user, MENTAL)
      physical_score = binder.score(user, PHYSICAL)
      diet_score = binder.score(user, DIET)
      message = "Ciao #{user.first_name}! Ecco a che punto sei arrivato fin'ora fin'ora! \n\n-Attivita' Fisica: #{physical_score} \n-Dieta: #{diet_score} \n-Salute Mentale: #{mental_score} \n\n\t Alcuni scoe potrebbero essere 0% se non hai nessuna attivita' inerente."
      send_message(user, message)
    end
  end

  def notify_deleted_plan(plan_name, user)
    message = "Ciao #{user.first_name}, ti informo che il coach ha ELIMINATO il piano #{plan_name}. Rimani in attesa per altri piani!"
    send_message(user, message)
  end

  def notify_plan_finished(plan)
    message = "Ciao #{plan.user.first_name}, ti informiamo che il piano #{plan.name} e' finito. "
    send_message(plan.user, message)
  end

  def notify_plan_missing_feedback(plan)
    message = "Ciao #{plan.user.first_name}, ti informiamo che il piano #{plan.name} e' finito ma non ho ancora ricevuto tutto il feedback necessario per capire come sono andate le attivita'."
    send_message(plan.user, message)
    send_message(plan.user, "Ti consiglio di fornirli al piu' presto.")
  end

  def notify_for_new_messages(user)
    message = "Ciao #{user.first_name}, il coach ti ha inviato dei nuovi messaggi. Vai nella sezione MESSAGGI per visualizzarli e rispondere."
    send_message(user, message)
  end

  def notify_for_new_activities(plan)
    user = plan.user
    message = "Nuove Attivita' sono state definite per te #{user.first_name}. Vai nella sezione ATTIVITA' per avere ulteriori dettagli."
    send_message(user, message)
  end

  def check_and_notify
    puts 'Looking for users to be Notified...'
    users = User.joins(:plans).where(:plans => {:delivered => 1})
    users.each do |user|
      message = need_to_be_notified?(user)
      unless message.nil?
        send_message(user, message)
      end
    end
  end

  def need_to_be_notified?(user)
    message = "Ciao #{user.last_name}! Ti ricordo che hai le seguenti attivita' programmate per oggi \n"
    flag = false
    plans = user.plans.where(:delivered => 1)
    plans.each do |plan|
      plan.plannings.each do |planning|
        notifications = planning.notifications.where('date = ? AND sent = ? AND n_type = ? AND ( (? - time) < ? )', Date.today, false, 'ACTIVITY_NOTIFICATION', Time.now, 60.minutes)
        notifications.find_each do |notification|
          notification.sent = true
          notification.save!
          message += " -#{planning.activity.name}, alle ore #{notification.time.strftime('%H:%M')} \n"
          flag = true
        end
      end

    end
    flag ? message : nil
  end

  def create_notifications(plan)
    ap 'Creando notifiche per PIANO:'
    ap plan

    plannings = plan.plannings
    start_date = plan.from_day
    end_date = plan.to_day

    plannings.each do |planning|
      notification_time = user_preferred_time(plan)

      ap 'creando notifiche per ATTIVITA:'
      ap planning.activity

      case planning.activity.a_type
        when '0'
          create_notifications_daily(planning, start_date, end_date, notification_time)
        when '1'
          create_notifications_weekly(planning, start_date, end_date, notification_time)
        else
          create_notifications_monthly(planning, start_date, end_date, notification_time)
      end
    end
  end

  def create_notifications_daily(planning, start_date, end_date, time)
    (start_date..end_date).each do |date|
      set(Notification.new(time: time, date: date, done: 0, n_type: 'ACTIVITY_NOTIFICATION'), planning)
    end
    planning.save
  end

  def create_notifications_weekly(planning, start_date, end_date, time)
    if planning.schedules.present?
      (start_date..end_date).each do |date|
        planning.schedules.each do |schedule|
          if date.wday == schedule.day + 1
            set(Notification.new(time: time, date: date, done: 0, n_type: 'ACTIVITY_NOTIFICATION'), planning)
          end
        end
      end
    else
      loop_through('week', start_date, end_date, planning, time)
    end
    planning.save
  end

  def create_notifications_monthly(planning, start_date, end_date, time)
    loop_through('month', start_date, end_date, planning, time)
    planning.save
  end

  private

  # loops through a period with a step=by and
  # create default notifications based on period and number of times to do an activity
  def loop_through(by, start_date, end_date, planning, time)
    from = start_date
    to = end_date
    interval = by
    start = from
    n_times = planning.activity.n_times
    while start < to
      stop  = start.send("end_of_#{interval}")
      if stop > to
        stop = to
      end

      interval_start = Date.parse(start.inspect)
      interval_end = Date.parse(stop.inspect)
      step = ((interval_end - interval_start).to_i / n_times) + 1
      (interval_start..interval_end).step(step) do |date|
        set(Notification.new(time: time, done: 0, date: date, n_type: 'ACTIVITY_NOTIFICATION'), planning)
      end

      start = stop.send("beginning_of_#{interval}")
      start += 1.send(interval)
    end
  end

  def user_preferred_time(plan)
    physical_questionnaire_inv = Invitation.where('user_id = ? AND questionnaire_id = ?', plan.user.id, Questionnaire.where('title = ?', 'Salute').first.id).first
    morning_hour_question = QuestionnaireQuestion.where('text like ?', '%mattina per ricevere le notifiche%').first
    user_preferred_hour_answer = QuestionnaireAnswer.where('invitation_id = ? AND questionnaire_question_id = ?', physical_questionnaire_inv.id, morning_hour_question.id).first
    Time.parse(user_preferred_hour_answer.text)
  end

  def set(notification, planning)
    notification.sent = false
    notification.planning = planning
    notification.save!
    puts "data #{notification.date} ora #{notification.time}"
  end

  def send_message(user, message)
    token = Rails.application.secrets.bot_token
    api = ::Telegram::Bot::Api.new(token)
    api.call('sendMessage', chat_id: user.telegram_id, text: message)
  end

end
