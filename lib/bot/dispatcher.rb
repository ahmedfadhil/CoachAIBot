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

class Dispatcher
  attr_reader :message, :user

  def initialize(message, user)
    @message = message
    @user = user
  end

  ap 'WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW'
  ap @message

  # process the user state
  def process

    if @user.nil?
      # user needs to log in
      LoginManager.new(@message, @user).manage
    else

      # dispatch in function of user state
      hash_state = JSON.parse(user.get_user_state)
      dot_state = hash_state.to_dot
      state = dot_state.state

      if text == ':build mine' || text == ':reset'
        ChatscriptCompiler.new(text, @user, hash_state).manage
      else
        case state

          when 0, '0'
            ap '--------PROFILING--------'
            # dispatch to profiling
            ProfilingManager.new(text, @user, hash_state).manage

          when 1, '1'
            ap '--------MENU--------'
            # dispatch to monitoring

            case text
              when 'attivita', '/attivita', 'Attivita'
                ap "---------SENDING ACTIVITIES FOR USER: #{@user.id} ----------"
                ActivityInformer.new(@user, hash_state).inform

              when 'feedback', '/feedback', 'Feedback'
                ap "---------CHECKING FOR FEEDBACK USER: #{@user.id}---------"
                FeedbackManager.new(@user, hash_state).check

              when '/messages', 'messaggi', 'Messaggi'
                ap "---------CHECKING MESSAGES FOR USER: #{@user.id}---------"
                Messenger.new(@user, hash_state).inform

              else # 'tips', 'consigli', 'Consigli', '/consigli', '/Consigli',  '/tips', 'Tips'
                MonitoringManager.new(text, @user, hash_state).manage

            end

          when 2, '2'
            ap "--------FEEDBACKING USER: #{@user.id} --------"
            # dispatch to feedback
            general_actions = GeneralActions.new(@user, hash_state)
            feedback_manager = FeedbackManager.new(@user, hash_state)
            names = GeneralActions.plans_names(general_actions.plans_needing_feedback)

            if hash_state['plan_name'].nil?
              case text
                when *tell_me_more_strings
                  feedback_manager.send_details

                when *back_strings
                  general_actions.back_to_menu_with_menu

                when *names
                  plan_name = text
                  ap "---------ASKING FEEDBACK FOR PLAN: #{plan_name} BY USER: #{@user.id}---------"
                  feedback_manager.ask(plan_name)

                else
                  feedback_manager.please_choose(names)
              end
            else
              case text
                when *back_strings
                  general_actions.back_to_menu_with_menu

                else
                  AnswerChecker.new(@user, hash_state).respond(text)
              end
            end

          when 3, '3'
            ap "---------RECEIVING RESPONSE FOR COACH MESSAGE BY USER: #{@user.id}---------"
            general_actions = GeneralActions.new(@user, hash_state)

            case text
              when *back_strings
                general_actions.back_to_menu_with_menu
              else
                Messenger.new(@user, hash_state).register_patient_response(text)
            end


        end
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