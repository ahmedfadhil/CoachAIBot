require 'telegram/bot'

class Feedback_Manager
  attr_reader :user, :state, :api

  def initialize(user, state)
    @user = user
    token = Rails.application.secrets.bot_token
    @api = ::Telegram::Bot::Api.new(token)
    @state = state
  end

  def check
    delivered_plans = plans_to_be_notified
    plan_names = plans_names delivered_plans

    if delivered_plans.size > 0 && !delivered_plans.nil?
      reply = "Dovresti fornire feedback per i seguenti Piani ed Attivita':\n"
      send_reply reply
      i = 0
      delivered_plans.each do |plan|
        j = 0
        reply = "#{i+1} Piano: '#{plan.name}' \t\tCon le seguenti attivita':"
        send_reply reply
        plan.plannings.find_each do |planning|
          notifications = planning.notifications.where('notifications.date<=?', Date.today)
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

      plans_keyboard = custom_keyboard plan_names
      @state = @state.except 'plan_id', 'notification_id', 'question_id'

      @api.call('sendMessage', chat_id: @user.telegram_id,
                text: 'Per che piano vuoi fornire il feedback?', reply_markup: plans_keyboard)

      # set feedback state
      set_state 2

    else
      reply = 'Per ora non c\'e\' piu\' feedback da dare. Prosegui con le attivita e potrai dare feedback su di esse.'
      back_to_monitoring @state
      keyboard = custom_keyboard ['Attivita', 'Feedback', 'Consigli']
      @api.call('sendMessage', chat_id: @user.telegram_id,
                text: reply, reply_markup: keyboard)
    end


  end

  def ask(plan_name)
    notification = Notification.joins(planning: :plan)
        .where('notifications.date<=? AND notifications.done=? AND plans.delivered=? AND plans.name=?',
               Date.today, 0, 1, plan_name)
        .limit(1)[0]

    if notification.nil?
      reply = "Abbiamo finito con il piano ''#{plan_name}''"
      @api.call('sendMessage', chat_id: @user.telegram_id, text: reply)
      clean @state
      Feedback_Manager.new(@user, @state).check
    else
      ap "NOTIFICATION= #{notification.date} #{notification.time}"
      ap "FEEDBACK= #{notification.feedbacks.size} QUESTIONS= #{notification.planning.activity.questions.size}"
      if notification.feedbacks.size<notification.planning.activity.questions.size
        question = notification.planning.activity.questions[notification.feedbacks.size]
        reply = "In data #{notification.date} alle ore #{notification.time.strftime('%H:%M')} \n"
        reply = reply + "\n\t #{question.text}?"
        answers = answers_from question.answers

        keyboard = custom_keyboard(answers)
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
        @state = @state.except('plan_name', 'notification_id', 'question_id')
        Feedback_Manager.new(@user, @state).check
      end
    end
  end

  def please_choose(plans)
    if plans.size==0
      back_to_monitoring(@state)
    else
      reply = 'Per favore scegli uno dei piani indicati'
      @api.call('sendMessage', chat_id: @user.telegram_id,
                text: reply, reply_markup: custom_keyboard(plans))
    end
  end

  private

    def back_to_monitoring(state)
      state['state'] = 1
      user.set_user_state state.except 'plan_name', 'notification_id', 'question_id'
    end

    def plans_to_be_notified
      Plan.joins(plannings: :notifications).where('notifications.date<=? AND notifications.done=? AND plans.delivered=?', Date.today, 0, 1).uniq
    end

    def clean(state)
      state.except('plan_name', 'notification_id', 'question_id')
      @user.set_user_state state
    end

    def answers_from(answers)
      list = []
      answers.each do |a|
        list.push a.text
      end
      list
    end

    def set_state(state)
      # set feedback state
      @state['state'] = state
      user.set_user_state @state
    end

    def plans_names(delivered_plans)
      plans_names = []
      delivered_plans.map do |p|
        plans_names.push  p.name
      end
      plans_names.push 'Torna Indietro'
      plans_names
    end

    def custom_keyboard(keyboard_values)
      kb = slice_keyboard keyboard_values
      answers =
          Telegram::Bot::Types::ReplyKeyboardMarkup
              .new(keyboard: kb, one_time_keyboard: true)
      answers
    end

    def slice_keyboard(keyboard)
      if keyboard.length > 3
        kb = keyboard.each_slice(2).to_a
      else
        kb = keyboard
      end
      kb
    end


    def send_reply(reply)
      @api.call('sendMessage', chat_id: @user.telegram_id, text: reply)
    end

    def set_plan(plan_name)
      @state['plan_name'] = plan_name
      user.set_user_state @state
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