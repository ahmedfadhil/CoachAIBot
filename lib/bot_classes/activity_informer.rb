require 'telegram/bot'
require 'bot_classes/general_actions'

class ActivityInformer
  attr_reader :user, :api, :state

  def initialize(user, state)
    @user = user
    token = Rails.application.secrets.bot_token
    @api = ::Telegram::Bot::Api.new(token)
    @state = state
  end

  def inform
    actuator = GeneralActions.new(@user, @state)
    delivered_plans = @user.plans.where(:delivered => 1)
    delivered_plans_names = delivered_plans.map(&:name)
    if delivered_plans.size > 0
      actuator.send_plans_details(delivered_plans)
      inform_about delivered_plans_names
    else
      reply = 'Momentaneamente non ci sono attivita\' da fare. Ricontrolla piu\' tardi.'
      actuator.send_reply_with_keyboard(reply,GeneralActions.menu_keyboard)
    end
  end

  private

  def inform_about(delivered_plans_names)
    another_actuator = GeneralActions.new(@user,@state)
    another_actuator.send_chat_action 'typing'
    reply = "In breva hai da seguire i seguenti piani: \n\n"
    reply += "\t-#{delivered_plans_names.join("\n\t-")}"
    another_actuator.send_reply_with_keyboard(reply,GeneralActions.menu_keyboard)
  end

end