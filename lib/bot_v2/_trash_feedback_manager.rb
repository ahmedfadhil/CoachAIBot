require 'bot_v2/general'
require 'bot_v2/general'

class FeedbackManager
  attr_reader :user, :state

  def initialize(user, state)
    @user = user
    @state = state
  end

  def has_plans_to_feedback?
    plans_to_feedback = Plan.joins(plannings: :notifications)
        .where('notifications.date<=? AND notifications.done=? AND plans.delivered=? AND plans.user_id=?',
               Date.today, 0, 1, @user.id)
        .uniq
    (plans_to_feedback.size > 0 && !plans_to_feedback.nil?)
  end

  def undone_feedbacks?
    delivered_plans = GeneralActions.new(@user, @state).plans_needing_feedback
    (delivered_plans.size > 0 && !delivered_plans.nil?)
  end

  def inform_no_feedbacks
    if @user.profiled?
      reply = "Per ora non c'è feedback da dare. Per poter dare feedback devi avere delle attività da fare."
    else
      reply = "Per ora non c'è feedback da dare. Completa prima i questionari presenti nella sezione QUESTIONARI."
    end
    GeneralActions.new(@user, @state)
        .send_reply_with_keyboard(reply, GeneralActions.menu_keyboard)
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
    actuator.send_reply_with_keyboard("Quando avrai più tempo torna in questa sezione per fornire il tuo feedback sulle attivita' che avevi da fare.", GeneralActions.menu_keyboard)
  end

  def needs_feedback?(plan_name)
    n = Notification.joins(planning: :plan)
            .where('notifications.date<=? AND notifications.done=? AND plans.delivered=? AND plans.name=?', Date.today, 0, 1, plan_name)
            .limit(1)[0]
    !n.nil?
  end

  def ask_oldest_feedback(plan_name)
    notification = Notification.joins(planning: :plan)
                       .where('notifications.date<=? AND notifications.done=? AND plans.delivered=? AND plans.name=?', Date.today, 0, 1, plan_name)
                       .limit(1)[0]
    question = notification.planning.activity.questions[notification.feedbacks.size-1]
    prepare_bot(notification, question, plan_name)
    actuator = GeneralActions.new(@user, @state)
    answers = GeneralActions.answers_from_question question
    actuator.send_reply_with_keyboard("In data #{notification.date} - #{notification.time.strftime('%H:%m')}, \n\n\t #{question.text}?", GeneralActions.custom_keyboard(answers))

    if notification.feedbacks.size >= notification.planning.activity.questions.size
      notification.done = 1
      notification.save
    end
  end


  def is_answer(text)
    question = Question.find(@state['question_id'])
    answers = GeneralActions.answers_from_question question
    answers.include? text
  end

  def wrong_answer
    question = Question.find(@state['question_id'])
    answers = GeneralActions.answers_from_question question
    reply = 'Per favore rispondi con le opzioni a disposizione!'
    keyboard = GeneralActions.slice_keyboard answers
    actuator = GeneralActions.new(@user, @state)
    actuator.send_reply_with_keyboard reply, keyboard
  end


  def register_answer(answer)
    question = Question.find(@state['question_id'])
    notification = Notification.find(@state['notification_id'])
    feedback = Feedback.new(:answer => answer, :date => Date.today, :notification_id => @state['notification_id'],
                              :question_id => @state['question_id'])
    notification.feedbacks.size == question.answers.size ? notification.done = 1 : nil
    if feedback.save && notification.save
      @state = @state.except('notification_id', 'question_id')
      @user.bot_command_data = @state.to_json
      FeedbackManager.new(@user, @state).send_undone_feedbacks_continuing
    end

  end

  def send_undone_feedbacks_continuing
    actuator = GeneralActions.new(@user, @state)
    delivered_plans = GeneralActions.new(@user, @state).plans_needing_feedback
    plan_names = GeneralActions.plans_names delivered_plans
    if delivered_plans.empty?
      reply = 'Hai fornito feedback per tutti i piani. Prosegui con le attivita\' ora.'
      actuator.send_reply_with_keyboard reply, (GeneralActions.custom_keyboard plan_names)
    else

      @user = actuator.clean_state  # delete info about feedbacking from user's bot_command_data
      actuator.send_reply_with_keyboard 'Risposta Salvata. Con che piano vuoi proseguire il feedback?', (GeneralActions.custom_keyboard plan_names)
      actuator.send_reply should_feedback delivered_plans
    end
  end


  def please_choose_plan(plans)
    GeneralActions.new(@user, @state)
        .send_reply_with_keyboard('Per favore, scegli uno dei piani indicati, per fornire feedback sulla meno recente attivita che cera da fare.',
                                  GeneralActions.custom_keyboard(plans))
  end

  def should_feedback(plan_names)
    "In breve dovresti fornire feedback per i seguenti PIANI:\n\t-#{plan_names.map(&:name).join("\n\t-")}"
  end

  def finished(plan_name)
   "Hai dato tutti i feedback per il piano ''#{plan_name}'' dall'inizio fino ad oggi."
  end

  def send_finished_plan(plan_name)
    GeneralActions.new(@user, @state)
        .send_reply_with_keyboard(finished(plan_name),
                                  GeneralActions.plans_names(GeneralActions.new(@user, @state).plans_needing_feedback))
  end

  def prepare_bot(notification, question, plan_name)
    new_command_data = {'notification_id' => notification.id, 'question_id' => question.id, 'plan_name' => plan_name}
    @user.bot_command_data = new_command_data.to_json
  end


end