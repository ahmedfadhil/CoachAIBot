require 'telegram/bot'
require 'bot_classes/general_actions'

class FeedbackManager
  attr_reader :user, :state, :api

  def initialize(user, state)
    @user = user
    token = Rails.application.secrets.bot_token
    @api = ::Telegram::Bot::Api.new(token)
    @state = state
  end

  def send_details
    actuator = GeneralActions.new(@user, @state)
    plans = actuator.plans_needing_feedback
    actuator.send_feedback_details(plans)
    check
  end

  def check
    delivered_plans = GeneralActions.new(@user, @state).plans_needing_feedback
    plan_names = GeneralActions.plans_names delivered_plans
    if delivered_plans.size > 0 && !delivered_plans.nil?
      actuator = GeneralActions.new(@user, @state)
      actuator.send_reply should_feedback delivered_plans
      @user = actuator.clean_state  # delete info about feedbacking from user's bot_command_data
      actuator.send_reply_with_keyboard 'Per che piano vuoi fornire il feedback?', (GeneralActions.custom_keyboard plan_names)
      GeneralActions.new(@user, JSON.parse(@user.bot_command_data)).set_state 2 # set user state to feedback
    else
      actuator = GeneralActions.new(@user, @state)
      actuator.back_to_menu
      actuator.send_reply_with_keyboard 'Per ora non c\'e\' piu\' feedback da dare. Prosegui con le attivita e potrai dare feedback su di esse.', GeneralActions.menu_keyboard
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
        actuator.send_reply_with_keyboard("In data #{notification.date} alle ore #{notification.time.strftime('%H:%M')} \n\n\t #{question.text}?", GeneralActions.custom_keyboard(answers))
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
    "Dovresti fornire feedback per i seguenti PIANI:\n\t-#{plan_names.map(&:name).join("\n\t-")}"
  end

  def finished(plan_name)
   "Abbiamo finito con il piano ''#{plan_name}''"
  end

  def prepare_state_for_feedback(notification, question, plan_name)
    @state['notification_id'] = notification.id
    @state['question_id'] = question.id
    @state['plan_name'] = plan_name
    @user.set_user_state @state
  end

end