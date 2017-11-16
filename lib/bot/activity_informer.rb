require 'telegram/bot'
require 'bot/general_actions'

class ActivityInformer
  attr_reader :user, :api, :state

  def initialize(user, state)
    @user = user
    token = Rails.application.secrets.bot_token
    @api = ::Telegram::Bot::Api.new(token)
    @state = state
  end

  def check
    actuator = GeneralActions.new(@user, @state)
    actuator.set_state 5
    delivered_plans = @user.plans.where(:delivered => 1)
    delivered_plans_names = delivered_plans.map(&:name)
    if delivered_plans.size > 0
      inform_about delivered_plans_names
    else
      reply = 'Momentaneamente non ci sono attivita\' da fare. Ricontrolla piu\' tardi.'
      actuator.send_reply(reply)
      actuator.back_to_menu_with_menu
    end
  end

  def send_details
    actuator = GeneralActions.new(@user, @state)
    delivered_plans = @user.plans.where(:delivered => 1)
    actuator.send_plans_details(delivered_plans)
    actuator.back_to_menu_with_menu
  end

  private

  def inform_about(delivered_plans_names)
    actuator = GeneralActions.new(@user,@state)
    actuator.send_chat_action 'typing'
    reply = "In breve hai da seguire i seguenti piani: \n\n"
    reply += "\t-#{delivered_plans_names.join("\n\t-")}"
    actuator.send_reply_with_keyboard(reply,GeneralActions.custom_keyboard(['Ulteriori Dettagli', 'Torna al Menu']))
  end

end