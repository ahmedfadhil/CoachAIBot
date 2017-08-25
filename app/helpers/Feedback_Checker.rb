require 'telegram/bot'

class Feedback_Checker
  attr_reader :user, :api, :reply, :state

  def initialize(user, state, text)
    @user = user
    token = Rails.application.secrets.bot_token
    @api = ::Telegram::Bot::Api.new(token)
    @state = state
    @reply = ''
  end

  def check
    plan_names = []
    delivered_plans = @user.plans.where(:delivered => true)
    delivered_plans.map do |p|
      plan_names.push p.name
    end
    if delivered_plans.size > 0
      @reply = "Tappa sul comando vicino al piano per fornire Feedback per il piano indicato.\n\n"+"Dovresti fornire feedback per i seguenti Piani ed Attivita':"
      send_reply
      i = 0
      delivered_plans.find_each do |plan|
        j = 0
        @reply = "#{i+1} Piano: '#{plan.name}' \n\t\tCon le seguenti attivita':"
        send_reply
        plan.plannings.find_each do |planning|
          notifications = planning.notifications.where('notifications.date<=?', Date.today)
          if notifications.size > 0
            notifications.each do |n|
              case planning.activity.a_type
                when 'daily'
                  @reply = "\t\t\t-Attivita' #{planning.activity.name} era da fare il #{n.date} alle ore #{n.time.strftime('%H:%M')}\n"
                  send_reply
                else
                  planning.activity.activity.a_type == 'weekly' ? period = 'a settimana' : period = 'al mese'
                  @reply = "\t\t\t-Attivita' #{planning.activity.name} da fare #{planning.activity.n_times} volte #{period} \n"
                  send_reply
              end
            end
          end
          break # DA ELIMINARE
          j = j + 1
        end
        break #DA ELIMINARE
        i = i + 1
      end
      # create and send a pdf document with feedbacks undone
      # @api.send_document(chat_id: message.from.id, document: Faraday::UploadIO.new('test.gif', 'image/gif'))

      plans_keyboard = custom_keyboard plan_names
      @api.call('sendMessage', chat_id: @user.telegram_id,
                text: 'Per che piano vuoi fornire il feedback?', reply_markup: plans_keyboard)

      # set feedback state
      @state[:state] = '200'
      @user.set_user_state @state

    else
      @reply = 'Ancora non ci sono attivita\' definite per te.'
      send_reply
    end


  end

  def send_reply
    @api.call('sendMessage', chat_id: @user.telegram_id, text: @reply)
  end

  def custom_keyboard(keyboard_values)
    if keyboard_values.length>=4
      kb = keyboard_values.each_slice(2).to_a
    else
      kb = keyboard_values
    end
    kb = add_emoji kb
    answers =
        Telegram::Bot::Types::ReplyKeyboardMarkup
            .new(keyboard: kb, one_time_keyboard: true)
    answers
  end

  def add_emoji(values)
    values.map! {|x|
        "\u{1F4DC} "+ x
    }
    values
  end

end