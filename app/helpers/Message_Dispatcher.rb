require 'telegram/bot'
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

        when 1
          ap '--------MONITORING--------'
          # dispatch to monitoring

          case text
            when 'attivita', '/attivita', 'Attivita'
              Activity_Informer.new(@user, hash_state).inform
            when 'feedback', '/feedback', 'Feedback'
              Feedback_Manager.new(@user, hash_state).check
            else
              Monitoring_Manager.new(text, @user, hash_state).manage
          end

        when 2
          ap '--------FEEDBACKING--------'
          ap text
          # dispatch to feedback
          names = plans_names

          if hash_state['plan_name'].nil?
            case text
              when 'Indietro', 'indietro', 'basta', 'Torna Indietro', 'Basta', 'back'
                ap '------BACK'
                back_to_monitoring hash_state
              when *names
                ap '---------PLAN NAME'
                plan_name = text
                Feedback_Manager.new(@user, hash_state).ask(plan_name)
              else
                ap '------CHOOOOOSE'
                Feedback_Manager.new(@user, hash_state).please_choose(names)
            end
          else
            case text
              when 'Indietro', 'indietro', 'basta', 'Torna Indietro', 'Basta', 'back'
                back_to_monitoring hash_state
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

  def plans_names
    plans_names = []
    delivered_plans = Plan.joins(plannings: :notifications)
                          .where('notifications.date<=? AND notifications.done=? AND plans.delivered=? AND time(notifications.time)<time(?)',
                                 Date.today, 0, 1, Time.now.strftime('%T'))
                          .uniq
    delivered_plans.map do |p|
      plans_names.push  p.name
    end
    plans_names
  end


  def back_to_monitoring(state)
    state['state'] = 1
    s = state.except 'plan_name'
    user.set_user_state s
  end

end