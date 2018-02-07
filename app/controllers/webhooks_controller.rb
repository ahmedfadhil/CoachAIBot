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
<<<<<<< HEAD
=======
      GeneralActions.new(@user,nil).send_reply 'Forse non ho capito bene cosa intendevi, potresti ripetere per favore?'
>>>>>>> c11d02a27049a1f80b4ce61492ed6e5159830aa5
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