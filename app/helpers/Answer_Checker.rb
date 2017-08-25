require 'telegram/bot'

class Answer_Checker
  attr_reader :user, :api, :state

  def initialize(user, state)
    @user = user
    token = Rails.application.secrets.bot_token
    @api = ::Telegram::Bot::Api.new(token)
    @state = state
  end

  def respond(answer)
    question = Question.find(@state['question_id'])
    notification = Notification.find(@state['notification_id'])
    answers = answers_from question.answers
    if answers.include? answer
      feedback = Feedback.new(:answer => 'answer', :date => Date.today,
                              :notification_id => @state['notification_id'], :question_id => @state['question_id'])
      if notification.feedbacks.size == question.answers.size
        notification.done = 1
      end
      if feedback.save && notification.save
        send_reply 'Risposta Salvata'
        @state = @state.except('notification_id', 'question_id')
        @user.set_user_state(@state)
        Feedback_Manager.new(@user, @state).ask(@state['plan_name'])
      end

    else
      reply = "Per favore rispondi con le opzioni a disposizione!"
      keyboard = slice_keyboard answers
      @api.call('sendMessage', chat_id: @user.telegram_id,
                text: reply, reply_markup: custom_keyboard(keyboard))
    end
  end

  def send_reply(reply)
    @api.call('sendMessage', chat_id: @user.telegram_id, text: reply)
  end

  def slice_keyboard(values)
    values.length>=4 ? values.each_slice(2).to_a : values
  end

  def custom_keyboard(keyboard_values)
    kb = slice_keyboard(keyboard_values)
    answers =
        Telegram::Bot::Types::ReplyKeyboardMarkup
            .new(keyboard: kb, one_time_keyboard: true)
    answers
  end

  def answers_from(answers)
    list = []
    answers.each do |a|
      list.push a.text
    end
    list
  end



end