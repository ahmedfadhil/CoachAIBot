# da cambiare tutti i require
require 'bot_v2/api_ai_redirecter'
require 'bot_v2/login_manager'


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

        when 'feedback_plans'
          manage_feedback_plans_state(text)

        when 'feedback_activities'
          manage_feedback_activities_state(text)

        when 'feedbacking'
          manage_feedbacking_state(text)

        when 'questionnaires'
          manage_questionnaires_state(text)

        when 'responding'
          manage_responding_state(text)

        when 'confirmation'
          manage_confirmation_state(text)

        else
          GeneralActions.new(@user,nil).send_reply 'Penso di non aver capito, potresti ripetere per favore?'
      end

    end
  end
  def manage_idle_state(text)
    case text
      # Activities & Plans
      when *activities_strings
        ap "---------CHECKING ACTIVITIES FOR USER: #{@user.id} ----------"
        @user.get_activities!

      # Feedbacks
      when *feedback_strings
        ap "---------CHECKING FOR FEEDBACK USER: #{@user.id}---------"
        @user.show_plans_to_feedback!

      # Messages
      when *messages_strings
        ap "---------CHECKING MESSAGES FOR USER: #{@user.id}---------"
        @user.get_messages!

      # Questionnaires
      when *questionnaires_strings
        ap "---------CHECKING QUESTIONNAIRES FOR USER: #{@user.id}---------"
        @user.start_questionnaires!

      else
        #ApiAIRedirector.new(text, @user).redirect
        GeneralActions.new(@user,nil).send_reply 'Non ho capito! Usa i bottoni per interagire per favore!'
    end
  end

  def manage_activities_state(text)
    ap "---------INFORMING ABOUT ACTIVITIES USER: #{@user.id}---------"
    case text
      when *back_strings
        @user.cancel!

      when *tell_me_more_strings
        @user.get_details!

      else
        GeneralActions.new(@user,nil).send_reply 'Non ho capito! Usa i bottoni per interagire per favore!'
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
        @user.respond!(text)
    end
  end


  def manage_feedback_plans_state(text)
    case text
      when *tell_me_more_strings
        @user.get_details!

      when *back_strings
        @user.cancel!

      else
        @user.show_activities_to_feedback!(text)
    end
  end

  def manage_feedback_activities_state(text)
    case text
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


  def manage_questionnaires_state(text)
    case text
      when *back_strings
        @user.cancel!
      else
        @user.start_responding!(text)
    end
  end

  def manage_responding_state(text)
    case text
      when *back_strings
        @user.cancel!
      when 'Torna alla domanda precedente'
        @user.cancel_last_answer!
      else
        @user.respond_questionnaire!(text)
    end
  end

  def manage_confirmation_state(text)
    case text
      when 'Si'
        @user.confirm!
      when 'No'
        @user.cancel_confirmation!
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

  def activities_strings
    ['attivita', 'Attivita', 'attività', 'Attività']
  end

  def questionnaires_strings
    ['questionari', 'Questionari', 'Prosegui con i questionari']
  end

  def messages_strings
    ['messaggi', 'Messaggi']
  end

  def feedback_strings
    ['feedback', 'Feedback']
  end

end