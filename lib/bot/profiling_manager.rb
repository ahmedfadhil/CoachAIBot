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

    # we also need to detect if chatscript collected features and if yes we need to store them
    feature = @user.feature

    if feature.health == 0 && dot_state.health == 1
      feature.health = 1
      feature.health_personality = dot_state.health_features.health_personality
      feature.health_wellbeing_meaning = dot_state.health_features.health_wellbeing_meaning
      feature.health_nutritional_habits = dot_state.health_features.health_nutritional_habits
      feature.health_drinking_water = dot_state.health_features.health_drinking_water
      feature.health_vegetables_eaten = dot_state.health_features.health_vegetables_eaten
      feature.health_energy_level = dot_state.health_features.health_energy_level
      feature.save
    end

    if feature.mental == 0 && dot_state.mental == 1
      feature.mental = 1
      feature.mental_nervous = dot_state.mental_features.mental_nervous
      feature.mental_depressed = dot_state.mental_features.mental_depressed
      feature.mental_effort = dot_state.mental_features.mental_effort
      feature.save
    end

    if feature.coping == 0 && dot_state.coping == 1
      feature.coping = 1
      feature.coping_stress = dot_state.coping_features.coping_stress
      feature.coping_sleep_hours = dot_state.coping_features.coping_sleep_hours
      feature.coping_energy_level = dot_state.coping_features.coping_energy_level
      feature.save
    end

    if feature.physical == 0 && dot_state.physical == 1
      feature.physical = 1
      feature.physical_sport = dot_state.physical_features.sport
      feature.physical_sport_frequency = dot_state.physical_features.physical_sport_frequency
      feature.physical_sport_intensity = dot_state.physical_features.physical_sport_intensity
      feature.physical_goal = dot_state.physical_features.physical_goal
      feature.save
    end

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
    if keyboard_values.length>4
      kb = add_emoji keyboard_values.each_slice(2).to_a
    else
      kb = add_emoji keyboard_values
    end
    Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb, one_time_keyboard: true)
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