# da cambiare tutti i require

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
      hash_state = JSON.parse(user.get_bot_command_data)
      aasm_state = hash_state['aasm_state']

      case aasm_state
        when 'idle'
          manage_idle_state(text)

        when 'messages'
          manage_messages_state(text)

        else

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

  def manage_idle_state(text)
    case text
      # Activities & Plans
      when /(\w|\s|.)*(([Aa]+[Tt]+[Ii]+[Vv]+[Ii]*[Tt]+[AaÀà]*)|([Pp]+[Ii]+[Aa]+[Nn]+([Ii]+|[Oo]+)))+(\w|\s|.)*/
        ap "---------CHECKING ACTIVITIES FOR USER: #{@user.id} ----------"
        @user.get_activities!

      # Feedbacks
      when /(\w|\s|.)*([Ff]+[Ee]+[Dd]+[Bb]+[Aa]*([Cc]+|[Kk]+))+(\w|\s|.)*/
        ap "---------CHECKING FOR FEEDBACK USER: #{@user.id}---------"

      # Messages
      when /(\w|\s|.)*([Mm]+[Ee]+[Ss]+[Aa]+[Gg]*[Ii])+(\w|\s|.)*/
        ap "---------CHECKING MESSAGES FOR USER: #{@user.id}---------"
        @user.get_messages!

      else
        ApiAIRedirector.new(text, @user, hash_state).redirect

    end
  end

  def manage_messages_state(text)
    case text
      # Respond Later
      when *back_strings
        ap "---------USER #{@user.id} CANCELLED MESSAGES RESPONDING ACTION---------"
        @user.cancel_messages!

      else
        ap "---------RECEIVING RESPONSE FOR COACH MESSAGE BY USER: #{@user.id}---------"
        @user.register_patient_response!(text)
    end
  end

end