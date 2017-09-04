require 'telegram/bot'
require 'chatscript'


class ProfilingManager
  attr_reader :message, :user, :api, :cs_bot, :user_state

  def initialize(message, user, user_state)
    @message = message
    @user = user
    token = Rails.application.secrets.bot_token
    @api = ::Telegram::Bot::Api.new(token)
    @cs_bot = ChatScript::Client.new bot: 'Harry'
    @user_state = user_state

    # Check if Chatscript server is online
    unless cs_bot.alive?
      puts '#################### ChatScript Local Server is OFF ########################'
      exit 0
    end
  end

  def manage
    # if is the first time when he enters in profiling, we initialize chatscript by sending 'start' message
    # and resetting any previous topic data saved on chatscript server side
    if @user_state.to_dot.first_time == '0'
      @message = 'start'
      cs_bot.volley ':reset', user: user.telegram_id
      first_time_done @user_state
    end

    # send the user state to chatscript server (oob stands for Out Of Band Message)
    user_state_json_oob = "[#{@user_state.to_json}]"
    cs_bot.volley "#{user_state_json_oob}", user: user.telegram_id

    # send the user text message
    volley = cs_bot.volley "#{@message}", user: user.telegram_id
    reply = volley.text

    # catch user state after chatscript interaction
    user_state_oob = volley.oob

    # process any change in the user state and calculate any default response
    keyboard_markup = process_oob user_state_oob

    # Some Log Info
    puts "\n ### USER_ID: #{@user.telegram_id} | USER_MSG: #{@message} ###\n"
    puts "\n ### USER_STATE_SENT: #{user_state_json_oob}} ###\n"
    puts "\n ### BOT_REPLY: #{reply} ### \n"
    puts "\n ### USER_STATE_RECEIVED: #{user_state_oob} ###\n"

    # Send Chatscript response to user thought telegram
    @api.call('sendMessage', chat_id: @user.telegram_id,
              text: reply, reply_markup: keyboard_markup)
  end

  def process_oob(oob)
    ap oob
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
        custom_keyboard %w(Attivita Feedback Consigli)
      else
        custom_keyboard default_responses
      end
    else
      nil
    end
  end

  def first_time_done(user_state)
    user_state[:first_time] = '1'
  end

  def custom_keyboard(keyboard_values)
    if (keyboard_values.length>4)
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
        when 'attivita fisica'
          "\u{1f93a}"+x
        when 'strategia di adattamento'
          "\u{1f914}"+x
        when 'sì', 'si', 'certo', 'ok', 'va bene', 'certamente', 'sisi', 'yea', 'yes', 'S'
          "\u{1f44d}"+x
        when 'no', 'nono', 'assolutamente no', 'eh no', 'n', 'N'
          "\u{1f44e}"+x
        when 'un po'
          "\u{1f44c}"+x
        when 'soleggiato'
          "\u{1f31e}"+x
        when 'piovoso'
          "\u{1f327}"+x
        when 'go on', 'avanti', 'proseguiamo pure', 'proseguiamo'
          "\u{23ed}"+x
        when 'stop for a while', 'stop', 'fermiamoci qui per ora', 'fermiamoci', 'basta'
          "\u{1f6d1}"+x
        when 'nutrizione'
          "\u{1f355}"+x
        when 'fitness'
          "\u{1f3cb}"+x
        when 'consapevolezza'
          "\u{1f64c}"+x
        when 'ancora'
          "\u{1f4aa}"+x
        when 'basta'
          "\u{1f3fc}"+x
        when 'sempre'
          "\u{1f922}"+x
        when 'quasi sempre'
          "\u{1f637}"+x
        when 'poche volte'
          "\u{1f644}"+x
        when 'quasi mai'
          "\u{1f642}"+x
        when 'mai'
          "\u{1f60a}"+x
        when 'benessere mentale'
          "\u{1f60c}"+x
        when 'feedback'
          "\u{1f607}"+x
        else
          x
      end
    }
    values
  end

end