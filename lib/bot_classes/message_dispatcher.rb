require 'telegram/bot'
require 'chatscript'
require 'bot_classes/activity_informer'
require 'bot_classes/feedback_manager'
require 'bot_classes/profiling_manager'
require 'bot_classes/monitoring_manager'
require 'bot_classes/general_actions'
require 'bot_classes/answer_checker'
require 'bot_classes/api_ai_redirecter'

class MessageDispatcher
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

      case state

        when '0'
          ap '--------PROFILING--------'
          # dispatch to profiling
          ProfilingManager.new(text, @user, hash_state).manage

        when 1
          ap '--------MENU--------'
          # dispatch to monitoring

          case text
            when 'attivita', '/attivita', 'Attivita'
              ap "---------SENDING ACTIVITIES FOR USER: #{@user.id} ----------"
              ActivityInformer.new(@user, hash_state).inform

            when 'feedback', '/feedback', 'Feedback'
              ap "---------CHECKING FOR FEEDBACK USER: #{@user.id}---------"
              FeedbackManager.new(@user, hash_state).check

            else # 'tips', 'consigli', 'Consigli', '/consigli', '/Consigli',  '/tips', 'Tips'
              MonitoringManager.new(text, @user, hash_state).manage

          end

        when 2
          ap "--------FEEDBACKING USER: #{@user.id} --------"
          # dispatch to feedback
          general_actions = GeneralActions.new(@user, hash_state)
          feedback_manager = FeedbackManager.new(@user, hash_state)
          names = GeneralActions.plans_names(general_actions.plans_needing_feedback)

          if hash_state['plan_name'].nil?
            case text
              when *back_strings
                general_actions.back_to_menu

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
                general_actions.back_to_menu

              else
                AnswerChecker.new(@user, hash_state).respond(text)
            end
          end
        end

      ap JSON.parse @user.bot_command_data
    end

  end

  def text
    @message[:message][:text]
  end

  def back_strings
    ['Indietro', 'indietro', 'basta', 'Torna Indietro', 'Basta', 'back']
  end

end