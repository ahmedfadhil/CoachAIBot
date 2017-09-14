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

  def upload_health_features
    ap 'RECEIVING HEALTH FEATURES'
    ap all_params
    user = User.find(all_params['user_id'])
    feature = user.feature
    if user.feature.nil?
      feature = Feature.new(all_params)
      feature.user_id = user.id
      feature.save
    else
      feature.health_personality = params.health_personality
      feature.health_wellbeing_meaning = params.health_wellbeing_meaning
      feature.health_nutritional_habits = params.health_nutritional_habits
      feature.health_drinking_water = params.health_drinking_water
      feature.health_vegetables_eaten = params.health_vegetables_eaten
      feature.health_energy_level = params.health_energy_level
      feature.save
    end
    render json: {status: 'OK'}, status: :ok
  end

  private
  def all_params
    params.require(:webhook).permit!
  end

end