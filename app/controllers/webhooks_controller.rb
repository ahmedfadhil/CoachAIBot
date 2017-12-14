require 'bot/dispatcher'

class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def callback
		begin
    	!webhook[:message].nil? ?  Dispatcher.new(webhook, user).process : nil
		rescue => e
			puts "EXCEPTION OCCURRED!"
			puts "Rescuing..."
			puts e.message
			puts e.backtrace
		end
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

  private
  def all_params
    params.require(:webhook).permit!
  end

end
