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
    text = "Ciao #{@user.last_name}! Ti elenchero' tutti i piani e le loro attivita' che hai da fare: \n\n"
    delivered_plans = @user.plans.where(:delivered => 1)
    if delivered_plans.size > 0
      i = 0
      delivered_plans.find_each do |plan|
        j = 1
        text = text + "\t #{i+1}. Piano: '#{plan.name}' \n\t\tCon le seguenti attivita':\n"
        plan.plannings.find_each do |planning|
          text = text + "\t\t\t #{j}. #{planning.activity.name}\n"
          j = j + 1
        end
        i = i + 1
      end
      text = text + "\n"

      if i==delivered_plans.size
        buttons = %w[Attivita Feedback Tips]
        keyboard = GeneralActions.custom_keyboard buttons
        @user.set_user_state @state
        @api.call('sendMessage', chat_id: @user.telegram_id, text: text, reply_markup: keyboard)
      else
        @api.call('sendMessage', chat_id: @user.telegram_id, text: text)
      end

    else
      keyboard = GeneralActions.custom_keyboard ['Attivita', 'Feedback', 'Consigli']
      @api.call('sendMessage', chat_id: @user.telegram_id,
                text: 'Ancora non ci sono attivit\' definite per te.', reply_markup: keyboard)
    end


  end
end