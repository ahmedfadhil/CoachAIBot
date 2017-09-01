require 'telegram/bot'
require 'awesome_print'
require 'bot_classes/general_actions'


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

        when 1
          ap '--------MENU--------'
          # dispatch to monitoring

          case text
            when 'attivita', '/attivita', 'Attivita'
              ap "---------SENDING ACTIVITIES FOR USER #{@user.id} ----------"
              Activity_Informer.new(@user, hash_state).inform

            when 'feedback', '/feedback', 'Feedback'
              ap '---------CHECKING FOR FEEDBACK---------'
              Feedback_Manager.new(@user, hash_state).check

            else
              Monitoring_Manager.new(text, @user, hash_state).manage
          end

        when 2
          ap "--------FEEDBACKING USER: #{@user.id} --------"
          # dispatch to feedback
          general_actions = GeneralActions.new(@user, hash_state)
          feedback_manager = Feedback_Manager.new(@user, hash_state)
          names = general_actions.plans_names(general_actions.plans_needing_feedback)

          if hash_state['plan_name'].nil?
            case text
              when *back_strings
                general_actions.back_to_menu

              when *names
                plan_name = text
                ap "---------ASKING FEEDBACK FOR PLAN: #{plan_name}---------"
                feedback_manager.ask(plan_name)

              else
                feedback_manager.please_choose(names)
            end
          else
            case text
              when *back_strings
                general_actions.back_to_menu

              else
                Answer_Checker.new(@user, hash_state).respond(text)
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