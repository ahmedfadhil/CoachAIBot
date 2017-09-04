require 'telegram/bot'

class GeneralActions
  attr_reader :user, :state, :api

  def initialize(user, state)
    @user = user
    token = Rails.application.secrets.bot_token
    @api = ::Telegram::Bot::Api.new(token)
    @state = state
  end

  def back_to_menu
    @state['state'] = 1
    @user.set_user_state @state.except 'plan_name', 'notification_id', 'question_id'
  end

  def clean_state
    @user.set_user_state @state.except('plan_name', 'notification_id', 'question_id')
  end

  def set_state(state)
    @state['state'] = state
    user.set_user_state @state
  end

  def send_reply(reply)
    @api.call('sendMessage', chat_id: @user.telegram_id, text: reply)
  end

  def set_plan_name(plan_name)
    @state['plan_name'] = plan_name
    user.set_user_state @state
  end

  def plans_needing_feedback
    Plan.joins(plannings: :notifications).where('notifications.date<=? AND notifications.done=? AND plans.delivered=? AND plans.user_id=?', Date.today, 0, 1, @user.id).uniq
  end

  # static methods

  def self.answers_from_question(question)
    question.answers.map(&:text)
  end

  def self.plans_names(delivered_plans)
    delivered_plans.map(&:name).push('Torna Indietro')
  end

  def self.custom_keyboard(keyboard_values)
    kb = GeneralActions.slice_keyboard keyboard_values
    Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb, one_time_keyboard: true)
  end

  def self.slice_keyboard(values)
    values.length >= 4 ? values.each_slice(2).to_a : values
  end
end