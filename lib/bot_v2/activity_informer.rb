require 'telegram/bot'
require 'bot_v2/general'

class ActivityInformer
  attr_reader :user, :api, :state

  def initialize(user, state)
    @user = user
    token = Rails.application.secrets.bot_token
    @api = ::Telegram::Bot::Api.new(token)
    @state = state
  end

  def send_activities
    delivered_plans = @user.plans.where(:delivered => 1)
    delivered_plans_names = delivered_plans.map(&:name)
    actuator = GeneralActions.new(@user,@state)
    actuator.send_chat_action 'typing'
    reply = "In breve hai da seguire i seguenti piani: \n\n"
    reply += "\t-#{delivered_plans_names.join("\n\t-")}"
    actuator.send_reply_with_keyboard(reply,GeneralActions.custom_keyboard(['Ulteriori Dettagli', 'Torna al Menu']))
  end

  def inform_no_activities
    actuator = GeneralActions.new(@user,@state)
    actuator.send_chat_action 'typing'
    if @user.profiled?
      reply = 'Momentaneamente non ci sono attivita\' da fare. Ricontrolla piu\' tardi.'
    else
      reply = 'Momentaneamente non ci sono attivita\' da fare. Completa prima i questionari presenti nella sezione QUESTIONARI.'
    end
    actuator.send_reply_with_keyboard(reply, GeneralActions.menu_keyboard)
  end

  def send_details
    actuator = GeneralActions.new(@user, @state)
    delivered_plans = @user.plans.where(:delivered => 1)
    actuator.send_plans_details(delivered_plans)
  end

  def activities_present?
    delivered_plans = @user.plans.where(:delivered => 1)
    delivered_plans.size > 0
  end

  def send_menu
    actuator = GeneralActions.new(@user, @state)
    actuator.send_reply_with_keyboard("Se hai bisogno di ulteriori dettagli torna nella sezione attivita'", GeneralActions.custom_keyboard(['Attivita', 'Feedback', 'Consigli', 'Messaggi']))
  end

end