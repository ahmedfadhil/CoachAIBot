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

    #@user.reset_user_state

    user_state_JSON_OOB = "[#{@user_state.to_json}]"
    v = cs_bot.volley "#{user_state_JSON_OOB}", user: user.telegram_id

    volley = cs_bot.volley "#{@message}", user: user.telegram_id

    #have to figure out how to split text in adeguate group of sentences
    reply = volley.text.to_a
    #reply = reply.scan(/[^\.!?]+[\.!?]/).map(&:strip)


    user_state_OOB = volley.oob

    # Some Log Info
    puts "\n ### USER_ID: #{@user.telegram_id} | USER_MSG: #{@message} ###\n"
    puts "\n ### USER_STATE_SENT: #{user_state_JSON_OOB}} ###\n"
    puts "\n ### BOT_REPLY: #{reply} ### \n"
    puts "\n ### USER_STATE_RECEIVED: #{user_state_OOB} ###\n"

    answers = process_OOB user_state_OOB

    send_message_to_telegram reply, answers


  end

  def process_OOB user_state_OOB
    answers=nil
    if user_state_OOB!=''
      old_user_state = @user_state.to_dot
      new_user_state = eval(user_state_OOB).to_dot

      change_user_state_on_updates old_user_state, new_user_state

      keyboard_values = new_user_state.buttons.to_a
      if (keyboard_values.length>4)
        kb = keyboard_values.each_slice(2).to_a
      else
        kb = keyboard_values
      end

      kb = add_emonji_on_buttons kb

      answers =
          Telegram::Bot::Types::ReplyKeyboardMarkup
              .new(keyboard: kb, one_time_keyboard: true)
    end
    return answers
  end


  def change_user_state_on_updates old_user_state, new_user_state
    # change user state only if state changed
    if check_if_state_changed old_user_state, new_user_state
      @user.set_user_state new_user_state
    end
  end


  def send_message_to_telegram(text, keyboard)
    if keyboard.nil?
      send_distinct_messages_no_buttons text
    else
      send_distinct_messages text, keyboard
    end
  end

  def send_distinct_messages(text, buttons)
    text.each_with_index do |t, index|
      if index == text.size - 1
        @api.call('sendMessage', chat_id: @user.telegram_id, text: t, reply_markup: buttons)
      else
        @api.call('sendMessage', chat_id: @user.telegram_id, text: t)
      end
    end
  end


  def send_distinct_messages_no_buttons(text)
    text.each_with_index do |t, index|
      @api.call('sendMessage', chat_id: @user.telegram_id, text: t)
    end
  end


  def add_emonji_on_buttons buttons
      # funzione che per qualsiasi oob mi aggiunge un emoji a mia scelta
      buttons.map! {|x|
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
    return buttons
  end

  #check if the state changed, return false otherwhise
  def check_if_state_changed old_dot_state, new_dot_state

    if old_dot_state.state == new_dot_state.state && old_dot_state.state == 0
      return true if new_dot_state.health != old_dot_state.health
      return true if new_dot_state.physical != old_dot_state.physical
      return true if new_dot_state.coping != old_dot_state.coping
      return true if new_dot_state.mental != old_dot_state.mental
    else
      return true
    end

    return false

  end

end