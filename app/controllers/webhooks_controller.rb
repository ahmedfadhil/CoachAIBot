require 'BotMessage_Dispatcher'

class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def callback
    BotMessageDispatcher.new(webhook, user).process
    render json: nil, status: :ok
  end

  def webhook
    params['webhook']
  end

  def from
    webhook[:message][:from]
  end

  def user
    @user ||= User.find_by(telegram_id: from[:id]) || register_user
  end

  def register_user
    @user = User.find_or_initialize_by(telegram_id: from[:id])
    @user.update_attributes!(first_name: from[:first_name], last_name: from[:last_name])
    @user
  end

  def update_user_state
    puts "RECEIVED POST #{params}"
    render json: nil, status: :ok
  end
end