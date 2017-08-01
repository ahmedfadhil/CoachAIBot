require 'Message_Dispatcher'

class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def callback
    Message_Dispatcher.new(webhook, user).process
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

  def update_user_state
    puts 'RECEIVED POST'
    ap params
    render json: nil, status: :ok
  end
end