require 'telegram/bot'
require 'chatscript'


class ChatScriptManager
  attr_reader :message, :user, :api, :cs_bot, :user_state

  def initialize(message, user, user_state)
    @message = message
    @user = user
    token = Rails.application.secrets.bot_token
    @api = ::Telegram::Bot::Api.new(token)
    @cs_bot = ChatScript::Client.new bot: 'Harry'
    @user_state = user_state

    # Check if Chatscript server is online
    unless cs_bot.alive?
      puts '#################### ChatScript Server is OFF ########################'
      exit 0
    end
  end

  def manage

    user_state_JSON_OOB = "[#{@user_state.to_json}]"
    v = cs_bot.volley "#{user_state_JSON_OOB}", user: user.telegram_id

    volley = cs_bot.volley "#{@message}", user: user.telegram_id
    reply = volley.text
    user_state_OOB = volley.oob

    # Some Log Info
    puts "\n ### USER_ID: #{@user.telegram_id} | USER_MSG: #{@message} ###\n"
    puts "\n ### USER_STATE_SENT: #{user_state_JSON_OOB}} ###\n"
    puts "\n ### BOT_REPLY: #{reply} ### \n"
    puts "\n ### USER_STATE_RECEIVED: #{user_state_OOB} ###\n"

    # Send Chatscript response to user thought telegram
    send_message reply

  end

  def process_OOB oob
    if oob != ''
      state_recieved = JSON.parse(oob)
      dot_state = state_recieved.to_dot
      predef_responses = dot_state.predefinited_responses

      if predef_responses != nil
        #create inline keyboard
      end

      #eliminate buttons from state
      new_state = state_recieved.except(:buttons)
      @user.bot_command_data = new_state.json
      save

      #return inline keyboard

    end
  end

  def send_message(text, options={})
    @api.call('sendMessage', chat_id: @user.telegram_id, text: text)
  end

  def f oob
    #checking if there are OOB messages sent by ChatScript bot
    if(oob!="")
      keyboard_values = oob.split(%r{,\s*})


      if (keyboard_values.length>4)
        kb = keyboard_values.each_slice(2).to_a
      else
        kb = keyboard_values
      end


      # funzione che per qualsiasi oob mi aggiunge un emoji a mia scelta
      kb.map! {|x|
        case x
          when 'health', 'salute', 'healthy diet', 'healthy diet', 'dieta', 'dieta salutare', 'mangiare bene'
            "\u{1f52c}"+x
          when 'attivita fisica'
            "\u{1f93a}"+x
          when 'strategia di adattamento'
            "\u{1f914}"+x
          when 'sì', 'si', 'certo', 'ok', 'va bene', 'certamente', 'sisi', 'yea', 'yes', 'S'
            "\u{1f44d}"+x
          when 'no', 'nono', 'assolutamente no', 'eh no', 'n', 'N'
            "\u{1f44e}"+x
          when 'un po'
            "\u{1f44c}"+x
          when 'soleggiato'
            "\u{1f31e}"+x
          when 'piovoso'
            "\u{1f327}"+x
          when 'go on', 'avanti', 'proseguiamo pure', 'proseguiamo'
            "\u{23ed}"+x
          when 'stop for a while', 'stop', 'fermiamoci qui per ora', 'fermiamoci', 'basta'
            "\u{1f6d1}"+x
          when 'nutrizione'
            "\u{1f355}"+x
          when 'fitness'
            "\u{1f3cb}"+x
          when 'consapevolezza'
            "\u{1f64c}"+x
          when 'ancora'
            "\u{1f4aa}"+x
          when 'basta'
            "\u{1f3fc}"+x
          when 'sempre'
            "\u{1f922}"+x
          when 'quasi sempre'
            "\u{1f637}"+x
          when 'poche volte'
            "\u{1f644}"+x
          when 'quasi mai'
            "\u{1f642}"+x
          when 'mai'
            "\u{1f60a}"+x
          when 'benessere mentale'
            "\u{1f60c}"+x
          when 'feedback'
            "\u{1f607}"+x
          else
            x
        end
      }

      answers =
          Telegram::Bot::Types::ReplyKeyboardMarkup
              .new(keyboard: kb, one_time_keyboard: true)
      return answers
    end
    return nil

  end

end