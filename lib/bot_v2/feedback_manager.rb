require 'bot_v2/general'

class FeedbackManager
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def inform_wrong_answer
    GeneralActions.new(@user, nil).send_reply("Oups! Sembra che tu abbia scelto una risposta non valida. Perfavore, scegli una delle risposte disponibili!")
    ask(command_data['in_feedback_activities']['activity_chosen'])
  end

  def register_last_answer(answer)
    bot_command_data = command_data
    activity = Activity.where(name: bot_command_data['in_feedback_activities']['activity_chosen']).first
    plan = Plan.where(name: bot_command_data['in_feedback_plans']['plan_chosen']).first
    notification = Notification.find(bot_command_data['in_feedback_activities']['notification_id'])
    notification.done = 1
    notification.save
    Feedback.create(answer: answer, date: Date.today,
                    notification: Notification.find(bot_command_data['in_feedback_activities']['notification_id']),
                    question: Question.find(bot_command_data['in_feedback_activities']['question_id']))
    actuator = GeneralActions.new(@user, nil)
    actuator.send_reply('Risposta Salvata!')
    actuator.send_reply("Molto bene #{@user.last_name}, mi hai fornito tutto il feedback necessario fino ad oggi per l'attivita' '#{activity.name}' del piano '#{plan.name}'")
    actuator.send_reply_with_keyboard("Per fornire feedback su altre attivita' entra nuovamente nella sezione FEEDBACK.", GeneralActions.menu_keyboard)
  end

  def is_last_question?
    bot_command_data = command_data
    activity = Activity.where(name: bot_command_data['in_feedback_activities']['activity_chosen']).first
    plan = Plan.where(name: bot_command_data['in_feedback_plans']['plan_chosen']).first
    notifications = Notification.joins(:planning).where('plannings.plan_id = ? AND plannings.activity_id = ? AND notifications.date <= ?', plan.id, activity.id, Date.today)
    current_notification = Notification.find(bot_command_data['in_feedback_activities']['notification_id'])
    last_notification = notifications.last
    if current_notification.id == last_notification.id && current_notification.feedbacks.count == activity.questions.count-1
      return true
    end
    false
  end

  def register_answer_and_continue(answer)
    bot_command_data = command_data
    activity = Activity.where(name: bot_command_data['in_feedback_activities']['activity_chosen']).first
    notification = Notification.find(bot_command_data['in_feedback_activities']['notification_id'])
    question = Question.find(bot_command_data['in_feedback_activities']['question_id'])
    Feedback.create(answer: answer, date: Date.today, notification: notification, question: question)
    GeneralActions.new(@user, nil).send_reply('Risposta Salvata!')
    if activity.questions.count == notification.feedbacks.count
      notification.done = 1
      notification.save
    end
    ask(bot_command_data['in_feedback_activities']['activity_chosen'])
  end

  def is_answer?(answer)
    command_data['in_feedback_activities']['answers'].include?(answer)
  end

  def inform_wrong_activity
    GeneralActions.new(@user, nil).send_reply_with_keyboard("Hai scelto un'attivita' che non conosco. Per favore, scegli una delle attivita' indicate!",GeneralActions.custom_keyboard(command_data['in_feedback_plans']['activities_that_need_feedback']))
  end

  def ask(activity_name)
    bot_command_data = command_data
    plan = Plan.where(:name => bot_command_data['in_feedback_plans']['plan_chosen']).first
    activity = Activity.where(:name => activity_name).first
    notification = Notification.joins(:planning).where('plannings.plan_id = ? AND plannings.activity_id =? and notifications.date <= ? AND notifications.done = ?', plan.id, activity.id, Date.today, 0).first
    question = activity.questions[notification.feedbacks.count]
    bot_command_data['in_feedback_activities'] = {'activity_chosen' => activity_name, 'notification_id' => notification.id, 'question_id' => question.id, 'answers' => question.answers.map(&:text)}
    BotCommand.create(user: @user, data: bot_command_data.to_json)
    reply = "#{question_header(notification)}: \n\n\t#{question.text}"
    GeneralActions.new(@user, nil).send_reply_with_keyboard(reply,GeneralActions.custom_keyboard(question.answers.map(&:text).push('Rispondi piu\' tardi/Torna al Menu')))
  end

  def valid_activity_name?(activity_name)
    command_data['in_feedback_plans']['activities_that_need_feedback'].include?(activity_name)
  end

  def inform_wrong_plan
    GeneralActions.new(@user, nil).send_reply_with_keyboard('Hai scelto un piano che non conosco. Per favore, scegli uno dei piani indicati!', GeneralActions.custom_keyboard(command_data['plans_to_feedback']))
  end

  def send_activities_that_need_feedback(plan_name)
    plan = Plan.where(:user => User.first, :name => plan_name).first
    activities_names = Activity.joins(plannings: :notifications).where('plannings.plan_id = ? AND notifications.date<=? AND notifications.done=?', plan.id, Date.today, 0).uniq.map(&:name)
    bot_command_data = command_data
    bot_command_data['in_feedback_plans'] = {'plan_chosen' => plan_name, 'activities_that_need_feedback' => activities_names}
    BotCommand.create(user: @user, data: bot_command_data.to_json)
    actuator = GeneralActions.new(@user, nil)
    actuator.send_reply "Le attivita' del piano '#{plan_name}' che hanno bisogno di feedback sono:\n\n\t-#{activities_names.join("\n\t-")}"
    actuator.send_reply_with_keyboard "Per quale attivita' vuoi fornire feedback?",(GeneralActions.custom_keyboard activities_names.push('Rispondi piu\' tardi/Torna al Menu'))
  end

  def valid_plan_name?(plan_name)
    command_data['plans_to_feedback'].include?(plan_name)
  end

  def inform_no_plans_to_feedback
    if @user.profiled?
      reply = "Per ora non c'e' feedback da dare. Prosegui con le attivita' se ne hai da fare oppure attendi che il coach te ne dia."
    else
      reply = "Per ora non c'e' feedback da dare. Completa prima i questionari presenti nella sezione QUESTIONARI."
    end
    GeneralActions.new(@user, nil)
        .send_reply_with_keyboard(reply, GeneralActions.menu_keyboard)
  end

  def send_plans_to_feedback
    plans = plans_to_feedback
    plan_names = plans.map(&:name)
    actuator = GeneralActions.new(@user, nil)
    command_data = {'plans_to_feedback' => plan_names}
    BotCommand.create(user_id: @user.id, data: command_data.to_json)
    actuator.send_reply "I piani che hanno bisogno di feedback sono:\n\t-#{plan_names.join("\n\t-")}"
    actuator.send_reply_with_keyboard 'Per che piano vuoi fornire feedback?', (GeneralActions.custom_keyboard (plan_names.push('Ulteriori Dettagli').push('Rispondi piu\' tardi/Torna al Menu')))
  end

  def has_plans_to_feedback?
    plans = plans_to_feedback
    (plans.size > 0 && !plans.nil?)
  end

  def plans_to_feedback
    Plan.joins(plannings: :notifications).where('notifications.date<=? AND notifications.done=? AND plans.delivered=? AND plans.user_id=?', Date.today, 0, 1, @user.id).uniq
  end

  def command_data
    JSON.parse(BotCommand.where(user: @user).last.data)
  end

  def send_menu
    actuator = GeneralActions.new(@user, nil)
    actuator.send_reply_with_keyboard("Va bene! Quando vorrai sapere di piu' sul feedback che devi fornire, torna alla sezione FEEDBACK.", GeneralActions.menu_keyboard)
  end

  def question_header(notification)
    planning = notification.planning
    activity = planning.activity
    case activity.a_type
      when '0'
        "Il giorno #{notification.date.strftime('%d.%m.%Y')}"
      when '1'
        week, turn = week_and_order('week', planning.plan, planning, notification)
        "Per la #{turn} volta durante la #{week} settimana"
      else
        month, turn = week_and_order('month', planning.plan, planning, notification)
        "Per la #{turn} volta durante il #{month} mese"
    end
  end

  def week_and_order(by, plan, planning, notification)
    # looping through months
    date = notification.date
    from = plan.from_day
    to = plan.to_day
    interval = by
    start = from
    week_number = 1
    while start < to
      stop  = start.send("end_of_#{interval}")
      if stop > to
        stop = to
      end

      interval_start = Date.parse(start.inspect)
      interval_end = Date.parse(stop.inspect)
      if interval_start<=date && interval_end>=date
        return week_number, Notification.where('planning_id = (?) AND date >= (?) AND date <= (?)', planning.id, interval_start, interval_end).index(notification)+1
      end

      start = stop.send("beginning_of_#{interval}")
      start += 1.send(interval)
      week_number = week_number + 1
    end
  end

  def time_format(datetime)
    datetime.strftime('%H:%M') unless datetime.blank?
  end
end