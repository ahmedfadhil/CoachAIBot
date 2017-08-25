require 'telegram/bot'

class Asker
  attr_reader :plan_name, :user

  def initialize(user, state, plan_name)
    @user = user
    @plan_name = plan_name
    token = Rails.application.secrets.bot_token
    @api = ::Telegram::Bot::Api.new(token)
    @state = state
  end

  def do
    case plan_name
      when 'TUTTI'

      else

    end
  end
end