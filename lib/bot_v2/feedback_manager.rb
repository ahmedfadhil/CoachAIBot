require 'bot_v2/general'

class FeedbackManager
  attr_reader :user, :state

  def initialize(user, state)
    @user = user
    @state = state
  end

  def undone_feedbacks?
    delivered_plans = GeneralActions.new(@user, @state).plans_needing_feedback
    (delivered_plans.size > 0 && !delivered_plans.nil?)
  end

  def inform_no_feedbacks
    GeneralActions.new(@user, @state)
        .send_reply_with_keyboard("Per ora non c'e' feedback da dare. Per poter dare feedback devi avere delle attivita' da fare.", GeneralActions.menu_keyboard)
  end

  def send_undone_feedbacks
    delivered_plans = GeneralActions.new(@user, @state).plans_needing_feedback
    plan_names = GeneralActions.plans_names delivered_plans
    actuator = GeneralActions.new(@user, @state)
    actuator.send_reply should_feedback delivered_plans
    @user = actuator.clean_state  # delete info about feedbacking from user's bot_command_data
    actuator.send_reply_with_keyboard 'Per che piano vuoi fornire il feedback?', (GeneralActions.custom_keyboard plan_names)
  end

  def send_details
    actuator = GeneralActions.new(@user, @state)
    plans = actuator.plans_needing_feedback
    actuator.send_feedback_details(plans)
    send_undone_feedbacks
  end

  def send_menu
    actuator = GeneralActions.new(@user, @state)
    actuator.send_reply_with_keyboard("Quando avrai piu' tempo torna in questa sezione per fornire il tuo feedback sulle attivita' che avevi da fare.", GeneralActions.custom_keyboard(['Attivita', 'Feedback', 'Consigli', 'Messaggi']))
  end

  def register_feedback(answer)
    question = Question.find(@state['question_id'])
    notification = Notification.find(@state['notification_id'])
    answers = GeneralActions.answers_from_question question
    if answers.include? answer
      feedback = Feedback.new(:answer => answer, :date => Date.today, :notification_id => @state['notification_id'],
                              :question_id => @state['question_id'])
      notification.feedbacks.size == question.answers.size ? notification.done = 1 : nil
      if feedback.save && notification.save
        send_reply 'Risposta Salvata'
        @state = @state.except('notification_id', 'question_id')
        @user.set_user_state(@state)
        FeedbackManager.new(@user, @state).ask(@state['plan_name'])
      end
    else
      reply = 'Per favore rispondi con le opzioni a disposizione!'
      keyboard = GeneralActions.slice_keyboard answers
      @api.call('sendMessage', chat_id: @user.telegram_id,
                text: reply, reply_markup: GeneralActions.custom_keyboard(keyboard))
    end
  end

  def needs_feedbacked?(plan_name)
    (Notification.joins(planning: :plan)
       .where('notifications.date<=? AND notifications.done=? AND plans.delivered=? AND plans.name=?', Date.today, 0, 1, plan_name)
       .limit(1)[0]).nil?
  end

  def ask_oldest_feedback(plan_name)
    notification = Notification.joins(planning: :plan)
                       .where('notifications.date<=? AND notifications.done=? AND plans.delivered=? AND plans.name=?', Date.today, 0, 1, plan_name)
                       .limit(1)[0]
    if !(notification.feedbacks.size == notification.planning.activity.questions.size)
      question = notification.planning.activity.questions[notification.feedbacks.size]
      prepare_bot_for_feedback(notification, question, plan_name)
      actuator = GeneralActions.new(@user, @state)
      answers = GeneralActions.answers_from_question question
      actuator.send_reply_with_keyboard("In data #{notification.date} - #{notification.time.strftime('%H:%m')}, \n\n\t #{question.text}?", GeneralActions.custom_keyboard(answers))
    else
      notification.done = 1
      notification.save
      @user.cancel!
    end
  end


  def ask(plan_name)
    notification = Notification.joins(planning: :plan)
        .where('notifications.date<=? AND notifications.done=? AND plans.delivered=? AND plans.name=?', Date.today, 0, 1, plan_name)
        .limit(1)[0]

    if notification.nil?
      actuator = GeneralActions.new(@user, @state)
      actuator.send_reply(finished(plan_name))
      @user = actuator.clean_state
      FeedbackManager.new(@user, JSON.parse(@user.bot_command_data)).check
    else
      if !(notification.feedbacks.size == notification.planning.activity.questions.size)
        question = notification.planning.activity.questions[notification.feedbacks.size]
        prepare_state_for_feedback(notification, question, plan_name)
        actuator = GeneralActions.new(@user, @state)
        answers = GeneralActions.answers_from_question question
        actuator.send_reply_with_keyboard("In data #{notification.date} - #{notification.hour}, \n\n\t #{question.text}?", GeneralActions.custom_keyboard(answers))
      else
        notification.done = 1
        notification.save
        @user = GeneralActions.new(@user, @state).clean_state
        FeedbackManager.new(@user, JSON.parse(@user.bot_command_data)).check
      end
    end
  end

  def please_choose(plans)
    actuator = GeneralActions.new(@user, @state)
    if plans.size==0
      actuator.back_to_menu
    else
      actuator.send_reply_with_keyboard('Per favore, scegli uno dei piani indicati, per fornire feedback sulla meno recente attivita che cera da fare.', GeneralActions.custom_keyboard(plans))
    end
  end

  private
  def should_feedback(plan_names)
    "In breve dovresti fornire feedback per i seguenti PIANI:\n\t-#{plan_names.map(&:name).join("\n\t-")}"
  end

  def finished(plan_name)
   "Hai dato tutti i feedback per il piano''#{plan_name}'' dall'inizio fino ad oggi."
  end

  def prepare_bot_for_feedback(notification, question, plan_name)
    new_command_data = {'notification_id' => notification.id, 'question_id' => question.id, 'plan_name' => plan_name}
    @user.bot_command_data = new_command_data
    @user.save
  end

end