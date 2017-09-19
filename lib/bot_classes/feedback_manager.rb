require 'telegram/bot'
require 'bot_classes/general_actions'

class FeedbackManager
  attr_reader :user, :state, :api

  def initialize(user, state)
    @user = user
    token = Rails.application.secrets.bot_token
    @api = ::Telegram::Bot::Api.new(token)
    @state = state
  end

  def check
    delivered_plans = GeneralActions.new(@user, @state).plans_needing_feedback
    plan_names = GeneralActions.plans_names delivered_plans
    if delivered_plans.size > 0 && !delivered_plans.nil?
      reply = "Dovresti fornire feedback per i seguenti Piani ed Attivita':\n"
      send_reply reply
      i = 0
      delivered_plans.each do |plan|
        j = 0
        reply = "#{i+1} Piano: '#{plan.name}' \t\tCon le seguenti attivita':"
        send_reply reply
        plan.plannings.find_each do |planning|
          notifications = planning.notifications.where('notifications.date<=? AND notifications.done=?', Date.today, 0)
          if notifications.size > 0
            notifications.each do |n|
              case planning.activity.a_type
                when 'daily'
                  reply = "\t\t\t-#{planning.activity.name} in data #{n.date} alle ore #{n.time.strftime('%H:%M')}\n"
                  send_reply reply
                else
                  planning.activity.a_type == 'weekly' ? period = 'a settimana' : period = 'al mese'
                  reply = "\t\t\t-#{planning.activity.name} da fare #{planning.activity.n_times} volte #{period} \n"
                  send_reply reply
              end
            end
          end
          #break
          j = j + 1
        end
        #break
        i = i + 1
      end
      # create and send a pdf document with feedbacks undone
      # @api.send_document(chat_id: message.from.id, document: Faraday::UploadIO.new('test.gif', 'image/gif'))

      plans_keyboard = GeneralActions.custom_keyboard plan_names

      ap' INITIALY user IS'
      ap @user
      ap 'AND state is'
      ap @state

      @user = GeneralActions.new(@user, @state).clean_state

      ap 'THEN user IS'
      ap @user
      ap 'AND state IS'
      ap @user.state

      @api.call('sendMessage', chat_id: @user.telegram_id,
                text: 'Per che piano vuoi fornire il feedback?', reply_markup: plans_keyboard)

      # set feedback state
      GeneralActions.new(@user, JSON.parse(@user.bot_command_data)).set_state 2

    else
      reply = 'Per ora non c\'e\' piu\' feedback da dare. Prosegui con le attivita e potrai dare feedback su di esse.'
      GeneralActions.new(@user, @state).back_to_menu
      keyboard = GeneralActions.custom_keyboard ['Attivita', 'Feedback', 'Consigli']
      @api.call('sendMessage', chat_id: @user.telegram_id,
                text: reply, reply_markup: keyboard)
    end
  end

  def ask(plan_name)
    notification = Notification.joins(planning: :plan)
        .where('notifications.date<=? AND notifications.done=? AND plans.delivered=? AND plans.name=?', Date.today, 0, 1, plan_name)
        .limit(1)[0]

    if notification.nil?
      reply = "Abbiamo finito con il piano ''#{plan_name}''"
      @api.call('sendMessage', chat_id: @user.telegram_id, text: reply)
      @user = GeneralActions.new(@user, @state).clean_state
      FeedbackManager.new(@user, JSON.parse(@user.bot_command_data)).check
    else
      ap "NOTIFICATION= #{notification.date} #{notification.time}"
      ap "FEEDBACK= #{notification.feedbacks.size} QUESTIONS= #{notification.planning.activity.questions.size}"
      if !(notification.feedbacks.size == notification.planning.activity.questions.size)
        question = notification.planning.activity.questions[notification.feedbacks.size]
        reply = "In data #{notification.date} alle ore #{notification.time.strftime('%H:%M')} \n"
        reply = reply + "\n\t #{question.text}?"
        answers = GeneralActions.answers_from_question question

        keyboard = GeneralActions.custom_keyboard(answers)
        @state['notification_id'] = notification.id
        @state['question_id'] = question.id
        @state['plan_name'] = plan_name
        @state['buttons'] = keyboard
        @user.set_user_state @state

        @api.call('sendMessage', chat_id: @user.telegram_id,
                  text: reply, reply_markup: keyboard)
      else
        notification.done = 1
        notification.save
        @user = GeneralActions.new(@user, @state).clean_state
        FeedbackManager.new(@user, JSON.parse(@user.bot_command_data)).check
      end
    end
  end

  def please_choose(plans)
    if plans.size==0
      GeneralActions.new(@user, @state).back_to_menu
    else
      reply = 'Scegli uno dei piani indicati, per fornire feedback sulla meno recente attivita che cera da fare.'
      @api.call('sendMessage', chat_id: @user.telegram_id,
                text: reply, reply_markup: GeneralActions.custom_keyboard(plans))
    end
  end

  def send_reply(reply)
    @api.call('sendMessage', chat_id: @user.telegram_id, text: reply)
  end


=begin
  def add_emoji_multidim(values)
    values.map! {|row|
      row.map!{|x|
        "\u{1F4DC} "+x
      }
    }
    values
  end

  def add_emoji(values)
    values.map!{|x|
        "\u{1F4DC} "+x
    }
    values
  end
=end

end