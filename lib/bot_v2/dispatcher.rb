require 'bot/activity_informer'
require 'bot/feedback_manager'
require 'bot/profiling_manager'
require 'bot/monitoring_manager'
require 'bot/general_actions'
require 'bot/answer_checker'
require 'bot/api_ai_redirecter'
require 'bot/login_manager'
require 'bot/chatscript_compiler'
require 'bot/messenger'
require 'bot/tips'

class Dispatcher
  attr_reader :message, :user

  def initialize(message, user)
    @message = message
    @user = user
  end

  # process the user state
  def process

    if @user.nil?
      # user needs to log in
      LoginManager.new(@message, @user).manage
    else

      # dispatch in function of user state
      hash_state = JSON.parse(user.get_user_state)
      dot_state = hash_state.to_dot
      aasm_state = hash_state['aasm_state']

      case aasm_state
        when 'messages'
          user.get_messages!
      end

    end
  end

  def text
    @message[:message][:text]
  end

  def back_strings
    ['Indietro', 'indietro', 'basta', 'Torna Indietro', 'Basta', 'back', 'Torna al Menu', 'Rispondi piu\' tardi/Torna al Menu']
  end

  def tell_me_more_strings
    ['Dimmi di piu', 'ulteriori dettagli', 'dettagli', 'di piu', 'Ulteriori Dettagli']
  end

end