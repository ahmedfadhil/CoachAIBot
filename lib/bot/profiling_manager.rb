require 'telegram/bot'
require 'chatscript'
require 'csv'
require './lib/bot/image_solver'


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
      feature.age = dot_state.health_features.age
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
      feature.work_physical_activity = dot_state.physical_features.work_physical_activity
      feature.foot_bicycle = dot_state.physical_features.foot_bicycle
      feature.save
    end

    @user.set_user_state(new_state)

    if flag == 1
      if new_state.monitoring == 1
        communicate_profiling_done! @user
        save_features_to_csv @user
        save_telegram_profile_img @user
        system 'rake python_clustering &'
        custom_keyboard %w(Attivita Feedback Consigli Messaggi)
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
      kb = keyboard_values.each_slice(2).to_a
    else
      kb = keyboard_values
    end
    Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb, one_time_keyboard: true)
  end

  def communicate_profiling_done!(user)
    communicator = Communicator.new
    communicator.communicate_profiling_finished user
  end

  def save_features_to_csv(user)
    path = Rails.root.join('csvs', 'features.csv')
    features = user.feature
    CSV.open(path, 'a+') do |csv|
      csv << [user.id, features.age, features.health_personality, decode_work_physical_activity(features.work_physical_activity),
              decode_foot_bicycle(features.foot_bicycle), decode_stress(features.coping_stress)]
    end
  end

  def create_data_set
    users = User.all
    users.each do |user|
      path = Rails.root.join('csvs', 'status_classification_dataset.csv')
      features = user.feature
      unless features.py_cluster.nil?
        CSV.open(path, 'a+') do |csv|
          csv << [user.id, "#{user.first_name} #{user.last_name}", features.age, features.health_personality, decode_work_physical_activity(features.work_physical_activity),
                  decode_foot_bicycle(features.foot_bicycle), decode_stress(features.coping_stress), features.py_cluster]
        end
      end
    end
  end

  def save_telegram_profile_img(user)
    begin
      solver = ImageSolver.new
      uri = solver.solve(user.telegram_id)
      stream = open(uri)
      file_name = stream.base_uri.to_s.split('/')[-1]
      user.profile_img = "profile_images/#{file_name}"
      path = Rails.root.join('app/assets/images/profile_images', file_name)
      IO.copy_stream(stream, path)
    rescue Exception
      user.profile_img = default_profile_img
    end
    user.save
  end

  def default_profile_img
    'rsz_user_icon.png'
  end

  def decode_work_physical_activity(code)
    case code
      when 0, '0'
        'Mostly sitting (Involves movement less than 30 minutes per week)'
      when 1, '1'
        'Moderate (involves both sitting and moving)'
      else #2
        'Mostly moving (Involves movement more than 3days per week)'
    end
  end

  def decode_foot_bicycle(code)
    case code
      when 0, '0'
        '1-2 times a week'
      when 1, '1'
        '> 3 times a week'
      else #2
        'Most of the time'
    end
  end

  def decode_stress(code)
    case code
      when 0, '0'
        'Low'
      when 1, '1'
        'Medium'
      else #2
        'High'
    end
  end

end