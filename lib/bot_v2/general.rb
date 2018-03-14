require 'telegram/bot'
require 'JSON'

class GeneralActions
  attr_reader :user, :state, :api

  def initialize(user, state)
    @user = user
    token = Rails.application.secrets.bot_token
    @api = ::Telegram::Bot::Api.new(token)
    @state = state
  end

  def back_to_menu_with_menu
    @api.call('sendMessage', chat_id: @user.telegram_id,
              text: "Va bene #{@user.first_name}. Quando avrai piu' tempo torna in questa sezione.", reply_markup:
                  GeneralActions.menu_keyboard)
  end

  def send_reply(reply)
    send_chat_action 'typing'
    @api.call('sendMessage', chat_id: @user.telegram_id, text: reply)
  end

  def send_reply_with_keyboard(reply, keyboard)
    @api.call('sendMessage', chat_id: @user.telegram_id, text: reply, reply_markup: keyboard)
  end


  def send_chat_action(action)
    @api.call('sendChatAction', chat_id: @user.telegram_id, action: action)
  end

  def plans_needing_feedback
    Plan.joins(plannings: :notifications).where('notifications.date<=? AND notifications.done=? AND plans.delivered=? AND plans.user_id=?', Date.today, 0, 1, @user.id).uniq
  end


  def send_doc(file_path)
    @api.call('sendDocument', chat_id: @user.telegram_id, document: Faraday::UploadIO.new(file_path, 'pdf'))
  end

  ######################
  # FOR QUESTIONNAIRES #
  ######################

  #######################

  # data.class has to be Hash
  def save_bot_command_data(data)
    BotCommand.create(user_id: @user.id, data: data.to_json)
  end

  def bot_command_data
    JSON.parse(BotCommand.where(user: @user).last.data)
  end



  # static methods

  def self.back_button_text
    'Rispondi piu\' tardi/Torna al Menu'
  end

  def self.menu_buttons
    %w[Attività Feedback Messaggi]
  end

  def self.answers_from_question(question)
    question.answers.map(&:text)
  end

  def self.plans_names(delivered_plans)
    delivered_plans.map(&:name).push('Ulteriori Dettagli').push('Torna al Menu')
  end

  def self.custom_keyboard(keyboard_values)
    kb = GeneralActions.slice_keyboard keyboard_values
    k = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb, one_time_keyboard: true)
    k
  end

  def self.slice_keyboard(values)
    values.length >= 4 ? values.each_slice(2).to_a : values
  end

  def self.menu_keyboard
    custom_keyboard GeneralActions.menu_buttons
  end

end
