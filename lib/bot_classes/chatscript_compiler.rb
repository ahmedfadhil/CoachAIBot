require 'telegram/bot'
require 'chatscript'

class ChatscriptCompiler
  attr_reader :message, :user, :api, :cs_bot, :user_state

  def initialize(message, user, user_state)
    @message = message
    @user = user
    token = Rails.application.secrets.bot_token
    @api = ::Telegram::Bot::Api.new(token)
    @cs_bot = ChatScript::Client.new bot: 'Harry'
    @user_state = user_state

    # Check if Chatscript server is online
    unless cs_bot.alive?
      puts '#################### ChatScript Local Server is OFF ########################'
      exit 0
    end
  end

  def manage

    # send the user text message
    volley = cs_bot.volley "#{@message}", user: user.telegram_id
    reply = volley.text

    # Send Chatscript response to user thought telegram
    @api.call('sendMessage', chat_id: @user.telegram_id, text: reply)

    ap '####### CHATSCRIPT COMPILED '
  end

  def text
    @message[:message][:text]
  end


end