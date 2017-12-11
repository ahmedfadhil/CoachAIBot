require 'telegram/bot'
require 'chatscript'

class LoginManager
  attr_reader :message, :user, :api, :cs_bot

  def initialize(message, user)
    @message = message
    @user = user
    token = Rails.application.secrets.bot_token
    @api = ::Telegram::Bot::Api.new(token)
  end

  # process the user state
  def manage
    case text
      when /\A\/start/
        welcome
      else
        contact.nil? ? phone_number = text : phone_number = contact_phone_number
        if valid(phone_number)
          init_user
        else
          not_allowed
        end
    end

  end

  def welcome
    @api.call('sendMessage', chat_id: chat_id,
              text: 'Benvenuto in CoachAI!')
    @api.call('sendMessage', chat_id: chat_id,
              text: 'Fornisci il tuo nr di telefono, per continuare.',
              reply_markup: contact_request_markup)
  end

  def init_user
    user.telegram_id = chat_id
    user.reset_user_state
    state = new_state
    user.set_user_state(state)
    user.feature = Feature.new(physical: 0, health: 0, mental: 0, coping: 0, user_id: user.id)
    if user.save
      @api.call('sendMessage', chat_id: chat_id,
                text: "Ciao #{user.last_name}! Io sono CoachAI")
    end
  end

  def not_allowed
    @api.call('sendMessage', chat_id: chat_id,
              text: 'Numero di telefono non abilitato.')
    @api.call('sendMessage', chat_id: chat_id,
              text: 'Reinserisci il numero di telefono.',
              reply_markup: contact_request_markup)
  end

  def valid(phone_number)
    user = User.find_by_cellphone(phone_number)
    if user.nil?
      false
    else
      @user = user
      true
    end
  end

  def contact_request_markup
    kb = [
        Telegram::Bot::Types::KeyboardButton.new(text: 'Condividi numero cellulare', request_contact: true)
    ]
    Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb, one_time_keyboard: true)
  end

  def new_state
    {state: '0',
     first_time: '0',
     health: 0,
     physical: 0,
     coping: 0,
     mental: 0,
     user_id: @user.id,
     user_name: @user.last_name,
     monitoring: 0,
     notification_hour_morning: nil,
     notification_hour_evening: nil,
     health_features: {
         age: nil,
         health_personality: nil,
         health_wellbeing_meaning: nil,
         health_nutritional_habits: nil,
         health_drinking_water: nil,
         health_vegetables_eaten: nil,
         health_energy_level: nil
     },
     physical_features: {
         sport: nil,
         physical_sport_frequency: nil,
         physical_sport_intensity: nil,
         work_physical_activity: nil,
         foot_bicycle: nil
     },
     coping_features: {
         coping_stress: nil,
         coping_sleep_hours: nil,
         coping_energy_level: nil
     },
     mental_features: {
         mental_nervous: nil,
         mental_depressed: nil,
         mental_effort: nil
     }
    }
  end

  def contact_phone_number
    @message[:message][:contact][:phone_number][2,12]
  end

  def contact
    @message[:message][:contact]
  end

  def text
    @message[:message][:text]
  end

  def from
    @message[:message][:from]
  end

  def chat_id
    @message[:message][:from][:id]
  end

  def message_
    @message.require(:message).permit!
  end

end