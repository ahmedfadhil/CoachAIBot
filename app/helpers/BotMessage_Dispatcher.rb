require 'BotManager_New'

class BotMessageDispatcher
  attr_reader :message, :user

  def initialize(message, user)
    @message = message
    @user = user
  end

  # process the user state
  def process

    state = JSON.parse(user.get_user_state)
    puts "#################### USER_STATE: #{state["state"]} ########################"

    if state["state"] != 'no_state'
      # if the state was already setted we forward the messagge to Chatscript server for a response


    else

      # we set the initial state through the BotManager::Start method

      start_command = BotManager::New.new(user, message)

      if start_command.should_start?
        start_command.start
      else
        # ask user if he want to start conversation
        start_command.should_start
      end
    end

  end

end