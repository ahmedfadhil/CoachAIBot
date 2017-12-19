require 'telegram/bot'
require 'chatscript'
require 'bot/general'

class Tips
  attr_reader :message, :user, :api, :cs_bot, :user_state

  def initialize(message, user, state)
    @message = message
    @user = user
    token = Rails.application.secrets.bot_token
    @api = ::Telegram::Bot::Api.new(token)
    @cs_bot = ChatScript::Client.new bot: 'Harry'
    @state = state

    # Check if Chatscript server is online
    unless cs_bot.alive?
      puts '#################### ChatScript Local Server is OFF ########################'
      exit 0
    end
  end

  def enter_tips
    GeneralActions.new(@user, @state).set_state 4
    forward_to_chatscript
  end

  def manage
    forward_to_chatscript
  end

  private

  def forward_to_chatscript
    # send the user state to chatscript server (oob stands for Out Of Band Message)
    user_state_json_oob = "[#{@state.to_json}]"
    cs_bot.volley "#{user_state_json_oob}", user: @user.telegram_id

    # Some Log Info
    puts "\n ### USER_ID: #{@user.telegram_id} | USER_MSG: #{@message} ###\n"
    puts "\n ### USER_STATE_SENT TO CHATSCRIPT: ###\n"
    ap JSON.parse(@state.to_json)

    # send the user text message
    volley = cs_bot.volley "#{@message}", user: @user.telegram_id
    reply = volley.text

    puts "\n ### CHATSCRIPT REPLY: #{reply} ###\n"

    # catch user state after chatscript interaction
    user_state_oob = volley.oob

    # process any change in the user state and calculate any default response
    keyboard_markup = process_oob user_state_oob

    # Some Log Info
    puts "\n ### USER_STATE_RECEIVED: ###\n"
    ap user_state_oob


    # Send Chatscript response to user thought telegram
    @api.call('sendMessage', chat_id: @user.telegram_id,
              text: reply, reply_markup: keyboard_markup)
  end

  def process_oob(oob)
    state_received = JSON.parse(oob)
    dot_state = state_received.to_dot
    flag = 0

    if state_received.key?('buttons')
      default_responses = dot_state.buttons
      new_state = state_received.except(:buttons)           # delete buttons from state
      flag = 1
    else
      new_state = state_received
    end

    # !!!!!!!!!!!!!!!!!!!!!!! ToDo
    # we also need to detect if chatscript collected features and if yes we need to store them

    @user.set_user_state(new_state)

    if flag == 1
      if new_state.monitoring == 1
        custom_keyboard %w(Attivita Feedback Consigli Messaggi)
      else
        custom_keyboard default_responses
      end
    else
      nil
    end
  end


  def custom_keyboard(keyboard_values)
    if keyboard_values.length>=4
      kb = keyboard_values.each_slice(2).to_a
    else
      kb = keyboard_values
    end
    kb = add_emoji kb
    answers =
        Telegram::Bot::Types::ReplyKeyboardMarkup
            .new(keyboard: kb, one_time_keyboard: true)
    answers
  end

  def add_emoji(values)
    values.map! {|x|
      case x
        when 'health', 'salute', 'healthy diet', 'healthy diet', 'dieta', 'dieta salutare', 'mangiare bene'
          "\u{1f52c}"+x
        when 'nutrizione'
          "\u{1f355}"+x
        when 'fitness'
          "\u{1f3cb}"+x
        when 'consapevolezza'
          "\u{1f64c}"+x
        when 'ancora'
          "\u{1f4aa} "+x
        when 'basta'
          "\u{1f3fc} "+x
        else
          x
      end
    }
    values
  end

end