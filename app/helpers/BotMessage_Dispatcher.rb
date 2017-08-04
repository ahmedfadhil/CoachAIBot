require 'telegram/bot'
require 'chatscript'
require 'ChatScript_Manager'

class BotMessageDispatcher
  attr_reader :message, :user, :api, :cs_bot

  def initialize(message)
    @message = message
    @user = User.find_by_telegram_id(chat_id)
    token = Rails.application.secrets.bot_token
    @api = ::Telegram::Bot::Api.new(token)
    # @cs_bot = ChatScript::Client.new # for initializing the chatscript servver
  end

  # process the user state and dispatch message to Chatscript manager
  # if the user provided all the informations required in order to use the service
  def process
    #@user.reset_user_state     # this line exists just for developing reasons
    if !@user.nil?
      hash_state = JSON.parse(user.get_user_state)
      # dot_state = hash_state.to_dot
      # state = dot_state.state
      ChatScriptManager.new(text, @user, hash_state).manage
    else
      if start?
        try_login_with_cellphone
      else
        should_start
      end
    end
  end

  # check if the user sent us the cell phone number and check it
  def should_start
    if !text.blank?
      check_cellphone(text)
    elsif !@message[:message][:contact].nil?
      send_message('catchato')
    else
      try_login_with_cellphone
    end
  end

  # cheks if user were registered by the coach
  def check_cellphone(phone)
    user = User.find_by_cellphone(phone)
    if user.nil?
      notify_not_allowed
    else
      register(user)
    end
  end

  # registers the user chat_id and initialize his state
  def register(user)
    user.telegram_id = chat_id
    # resetting previous state
    user.reset_user_state
    # creating the initial state
    state = generate_new_state 0
    user.set_user_state(state)     # setting
    if user.save
      send_message("Benvenuto #{user.last_name}! Io sono Coach AI (Artificial Intelligence) e sono qui per aiutarti con le tue attivita' di benessere e salute.")

      #we should also send an empty msg to Chatscript to inform that the user want to get into root topic
    end
  end

  # requests the cellphone number
  def try_login_with_cellphone
    @api.call('sendMessage', chat_id: chat_id,
              text: 'Per fare il Login e poter utilizzare il servizio sei pregato di condividere con noi il tuo numero di telefono cellulare.',
              reply_markup: contact_request_markup)
  end

  def notify_not_allowed
    @api.call('sendMessage', chat_id: chat_id,
              text: 'Ci dispiace ma in base al tuo numero di cellulare non sei abilitato ad utilizzare il sistema. Puoi solamente riprovare a inserire il tuo numero di cellulare',
              reply_markup: contact_request_markup)
  end

  def contact_request_markup
    kb = [
        Telegram::Bot::Types::KeyboardButton.new(text: 'Condividi numero cellulare', request_contact: true)
    ]
    Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb, one_time_keyboard: true)
  end

  def start?
    text =~ /\A\/start/
  end

  def generate_new_state(state)
    {state: state, health: 0, physical: 0, coping: 0, mental: 0}
  end

  def send_message(text, options={})
    @api.call('sendMessage', chat_id: chat_id, text: text, options: options)
  end

  def contact_provided
    @message[:message][:contact][:phone_number]
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

end