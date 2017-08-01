require 'telegram/bot'
require 'Profiling_Manager'
require 'Login_Manager'
require 'awesome_print'

class Message_Dispatcher
  attr_reader :message, :user

  def initialize(message, user)
    @message = message
    @user = user
  end

  # process the user state
  def process

    if @user.nil?
      # user needs to log in
      Login_Manager.new(@message, @user).manage
    else
      # dispatch in function of user state
      hash_state = JSON.parse(user.get_user_state)
      dot_state = hash_state.to_dot
      state = dot_state.state

      case state
        when '0'
          ap '--------PROFILING--------'
          # dispatch to profiling
          Profiling_Manager.new(text, @user, hash_state).manage
        else
          ap '--------MONITORING--------'
          #dispatch to monitoring

      end
    end

  end

  def text
    @message[:message][:text]
  end

end