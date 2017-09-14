require 'api-ai-ruby'
require 'telegram/bot'

class ApiAIRedirector
  attr_reader :user, :state, :telegram_api, :api_ai_client, :text

  def initialize(text, user, state)
    @text = text
    @user = user
    api_ai_token = Rails.application.secrets.api_ai_token
    @api_ai_client = ApiAiRuby::Client.new(:client_access_token => api_ai_token)
    telegram_token = Rails.application.secrets.bot_token
    @telegram_api = ::Telegram::Bot::Api.new(telegram_token)
    @state = state
  end

  def redirect
    response = @api_ai_client.text_request @text
    puts "\n ### API.AI REPLY: ### \n"
    ap response
    @telegram_api.call('sendMessage', chat_id: @user.telegram_id, text: response[:result][:fulfillment][:speech].to_s)
  end
end