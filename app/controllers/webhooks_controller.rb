require 'bot_v2/dispatcher'

class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def callback
    begin
      !webhook[:message].nil? ?  Dispatcher.new(webhook, user).process : nil
    rescue Exception => e
      ap 'Rescued from:'
      ap e
      ap e.backtrace
      GeneralActions.new(@user,nil).send_reply_to_new_user(from[:id], 'Forse non ho capito bene cosa intendevi, potresti ripetere per favore?')
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