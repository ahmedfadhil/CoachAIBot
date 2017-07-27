require 'telegram/bot'
require 'chatscript'
require 'ChatScript_Manager'

class BotMessageDispatcher
  attr_reader :message, :user, :api, :cs_bot

  def initialize(message, user)
    @message = message
    @user = user
    token = Rails.application.secrets.bot_token
    @api = ::Telegram::Bot::Api.new(token)
    @cs_bot = ChatScript::Client.new

  end

  # process the user state
  def process

    #@user.reset_user_state

    hash_state = JSON.parse(user.get_user_state)
    dot_state = hash_state.to_dot
    state = dot_state.state

    if state != 'no_state'
      # if the state was already setted we forward the messagge to Chatscript server for a response
      ChatScriptManager.new(text, @user, hash_state).manage

    else
      if should_start?
        start
      else
        # ask user if he want to start conversation
        should_start
      end

    end

  end

  def send_message(text, options={})
    @api.call('sendMessage', chat_id: @user.telegram_id, text: text)
  end

  def text
    @message[:message][:text]
  end

  def from
    @message[:message][:from]
  end

  def should_start?
    text =~ /\A\/start/
  end

  def start
    #first msg on start
    send_message('Ciao io sono CoachAI dove AI sta per Artificial Inteligence.')
    user.reset_user_state          #resetting previous state

    #creating the initial state
    state = generate_new_state 0

    user.set_user_state(state)     #setting

    #send empty msg to Chatscript to inform that the user want to get into root topic
  end

  def should_start
    u=User.first
    u.telegram_id=@user.telegram_id
    u.save
    send_message('Ciao! Io sono un robot che fa da personal trainer. Se vuoi iniziare a chattare con me '+
                     'digita /start')
  end

  def generate_new_state(state)
    {state: state, health: 0, physical: 0, coping: 0, mental: 0}
  end


end