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
require 'bot/objectives_manager'
require 'finite_state_machine/objectives_fsm'

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
      state = dot_state.state

      if text == ':build mine' || text == ':reset'
        ChatscriptCompiler.new(text, @user, hash_state).manage
      else
        case state

          #when 0, '0'
            #ap '--------PROFILING--------'
            # dispatch to profiling
            #ProfilingManager.new(text, @user, hash_state).manage

          when 1, '1', 0, '0'
            ap '--------MENU--------'
                       case text
              when 'attivita', '/attivita', 'Attivita'
                ap "---------CHECKING ACTIVITIES FOR USER: #{@user.id} ----------"
                ActivityInformer.new(@user, hash_state).check

              when 'feedback', '/feedback', 'Feedback'
                ap "---------CHECKING FOR FEEDBACK USER: #{@user.id}---------"
                FeedbackManager.new(@user, hash_state).check

              when '/messages', 'messaggi', 'Messaggi'
                ap "---------CHECKING MESSAGES FOR USER: #{@user.id}---------"
                Messenger.new(@user, hash_state).inform

              when '/consigli', 'consigli', 'Consigli', 'Tips'
                ap "---------PREPARING TIPS FOR USER: #{@user.id}---------"
                Tips.new(text, @user, hash_state).enter_tips
							when 'obiettivi', 'Obiettivi', 'obbiettivi', 'Obbiettivi', '/obbiettivi'
								ap "---USER OBJECTIVES FOR USER: #{@user.id}---"
								fsm = FSM::ObjectivesFSM.new @user
								actuator = GeneralActions.new(@user, hash_state)
								response = fsm.dialog
								fsm.continue_dialog
								if fsm.state != "terminated"
									hash_state['state'] = 'objectives'
									fsm.update_model!(hash_state)
									@user.set_user_state(hash_state)
									@user.save!
								end
								actuator.send_reply_with_keyboard response[:text], response[:keyboard]
              else
                ApiAIRedirector.new(text, @user, hash_state).redirect

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

          when 4, '4'
            ap "---------SENDING TIPS TO USER: #{@user.id}---------"
            Tips.new(text, @user, hash_state).manage
					when 'objectives'
						ap "--- objectives ---"
						fsm = FSM::ObjectivesFSM.from_model(@user, hash_state)
						actuator = GeneralActions.new(@user, hash_state)
						response = fsm.dialog(text)
						fsm.continue_dialog
						if fsm.state != "terminated"
							fsm.update_model!(hash_state)
							@user.set_user_state(hash_state)
							@user.save!
						else
							hash_state['state'] = 0
							@user.set_user_state(hash_state)
							@user.save!
						end
						actuator.send_reply_with_keyboard response[:text], response[:keyboard]

          else # when 5, '5'
            ap "---------INFORMING ABOUT ACTIVITIES USER: #{@user.id}---------"
            case text
              when *back_strings
                GeneralActions.new(@user, hash_state).back_to_menu_with_menu
              else # when 'Ulteriori Dettagli'
                ActivityInformer.new(@user, hash_state).send_details
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
