require 'bot_classes/message_dispatcher'

class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def callback
    !webhook[:message][:from].nil? ?  MessageDispatcher.new(webhook, user).process : nil
    render json: nil, status: :ok
  end

  def user
    @user = User.find_by(telegram_id: from[:id])
  end

  def webhook
    params['webhook']
  end

  def from
    webhook[:message][:from]
  end

  def user_id
    webhook[:user_id]
  end

  def update_user_state
    puts 'RECEIVED POST'
    ap params
    render json: nil, status: :ok
  end

end