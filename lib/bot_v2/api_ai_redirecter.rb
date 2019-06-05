require 'api-ai-ruby'
require 'telegram/bot'

class ApiAIRedirector
  attr_reader :user, :telegram_api, :api_ai_client, :text

  def initialize(text, user)
    @text = text
    @user = user
    api_ai_token = Rails.application.secrets.api_ai_token
    @api_ai_client = ApiAiRuby::Client.new(:client_access_token => api_ai_token)
    telegram_token = Rails.application.secrets.bot_token
    @telegram_api = ::Telegram::Bot::Api.new(telegram_token)
  end

  def redirect
    begin
      response = @api_ai_client.text_request @text
      @telegram_api.call('sendMessage', chat_id: @user.telegram_id, text: response[:result][:fulfillment][:speech].to_s)
    rescue Exception => e
      ap 'DialogFlow responded with:'
      ap response
      ap 'Rescued from:'
      ap e
      ap e.backtrace
      GeneralActions.new(@user,nil).send_reply 'Mi spiace ma non credo di saperti rispondere!'
    end
  end
end