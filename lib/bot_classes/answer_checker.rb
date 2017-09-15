require 'telegram/bot'
require 'bot_classes/feedback_manager'
require 'bot_classes/general_actions'

class AnswerChecker
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
    answers = GeneralActions.answers_from_question question
    if answers.include? answer
      feedback = Feedback.new(:answer => 'answer', :date => Date.today, :notification_id => @state['notification_id'],
                              :question_id => @state['question_id'])
      notification.feedbacks.size == question.answers.size ? notification.done = 1 : nil
      if feedback.save && notification.save
        send_reply 'Risposta Salvata'
        @state = @state.except('notification_id', 'question_id')
        @user.set_user_state(@state)
        FeedbackManager.new(@user, @state).ask(@state['plan_name'])
      end
    else
      reply = 'Per favore rispondi con le opzioni a disposizione!'
      keyboard = GeneralActions.slice_keyboard answers
      @api.call('sendMessage', chat_id: @user.telegram_id,
                text: reply, reply_markup: GeneralActions.custom_keyboard(keyboard))
    end
  end

  def send_reply(reply)
    @api.call('sendMessage', chat_id: @user.telegram_id, text: reply)
  end

end