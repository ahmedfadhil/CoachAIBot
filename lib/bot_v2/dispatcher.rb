# da cambiare tutti i require

require 'bot/api_ai_redirecter'
require 'bot/login_manager'


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

      # dispatch in function of user state and text input
      aasm_state = @user.aasm_state
      ap "CURRENT USER: #{@user.id} STATE: #{aasm_state}"
      case aasm_state
        when 'idle'
          manage_idle_state(text)

        when 'activities'
          manage_activities_state(text)

        when 'messages'
          manage_messages_state(text)

        when 'feedbacks'
          manage_feedbacks_state(text)

        else # 'feedbacking'
          manage_feedbacking_state(text)

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
        @user.show_undone_feedbacks!

      # Messages
      when /(\w|\s|.)*([Mm]+[Ee]+[Ss]+[Aa]+[Gg]*[Ii])+(\w|\s|.)*/
        ap "---------CHECKING MESSAGES FOR USER: #{@user.id}---------"
        @user.get_messages!

      else
        hash_state = JSON.parse(@user.bot_command_data)
        ApiAIRedirector.new(text, @user, hash_state).redirect

    end
  end

  def manage_activities_state(text)
    ap "---------INFORMING ABOUT ACTIVITIES USER: #{@user.id}---------"
    case text
      when *back_strings
        @user.cancel!

      else # when 'Ulteriori Dettagli'
        @user.get_details!
    end
  end

  def manage_messages_state(text)
    case text
      # Respond Later
      when *back_strings
        ap "---------USER #{@user.id} CANCELLED MESSAGES RESPONDING ACTION---------"
        @user.cancel!

      else
        ap "---------RECEIVING RESPONSE FOR COACH MESSAGE BY USER: #{@user.id}---------"
        @user.register_patient_response!(text)
    end
  end

  def manage_feedbacks_state(text)
    case text
      when *tell_me_more_strings
        @user.get_details!

      when *back_strings
        @user.cancel!

      else
        @user.start_feedbacking!(text)

    end
  end

  def manage_feedbacking_state(text)
    case text
      when *back_strings
        @user.cancel!
      else
        @user.feedback!(text)
    end
  end

end