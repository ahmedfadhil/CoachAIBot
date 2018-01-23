require 'telegram/bot'
require 'chatscript'
require "#{Rails.root}/lib/bot_v2/general"

class LoginManager
  attr_reader :message, :user, :api, :cs_bot

  def initialize(message, user)
    @message = message
    @user = user
    token = Rails.application.secrets.bot_token
    @api = ::Telegram::Bot::Api.new(token)
  end

  # process the user state
  def manage
    case text
      when /\A\/start/
        welcome
      else
        contact.nil? ? phone_number = nil : phone_number = contact_phone_number
        if valid(phone_number)
          init_user
        else
          not_allowed
        end
    end
  end

  def welcome
    @api.call('sendMessage', chat_id: chat_id,
              text: 'Benvenuto in CoachAI!')
    @api.call('sendMessage', chat_id: chat_id,
              text: 'Fornisci il tuo nr di telefono attraverso il bottone per continuare.',
              reply_markup: contact_request_markup)
  end

  def init_user
    user.telegram_id = chat_id
    if user.save
      reply = "Ciao #{user.last_name}! Io sono CoachAI, il bot che ti tiene in contatto con il tuo coach. Attraverso me potrai fare le seguenti cose:\n" +
          "\n-Ricevere e visualizzare le attivita' che ti vengono assegnate dal coach #{@user.coach_user.first_name} #{@user.coach_user.last_name}" +
          "\n-Fornire feedback sulle attivita' che avevi da fare mano a mano che le fai, per fare in modo che il tuo coach sappia i tuoi progressi" +
          "\n-Ricevere messaggi diretti dal tuo coach e rispondergli con facilita'"
      @api.call('sendMessage', chat_id: chat_id,
                text: reply)
      reply = "Prima di poter utilizzarmi in questo modo pero' devi completare i questionari presenti nella sezione QUESTIONARI. Non dimenticartelo!\n\n" +
            "Questa cosa e' fondamentale per capire bene qual'e' il tuo stato attuale."
      @api.call('sendMessage', chat_id: chat_id,
                text: reply, reply_markup: GeneralActions.menu_keyboard)
    end
  end

  def not_allowed
    @api.call('sendMessage', chat_id: chat_id,
              text: 'Numero di telefono non abilitato.')
    @api.call('sendMessage', chat_id: chat_id,
              text: 'Fornisci il tuo nr di telefono attraverso il bottone per continuare.',
              reply_markup: contact_request_markup)
  end

  def valid(phone_number)
    user = User.find_by_cellphone(phone_number)
    if user.nil?
      false
    else
      @user = user
      true
    end
  end

  def contact_request_markup
    kb = [Telegram::Bot::Types::KeyboardButton.new(text: 'Condividi numero cellulare', request_contact: true)]
    Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb, one_time_keyboard: true)
  end

  def contact_phone_number
    # phone number without prefix
    @message[:message][:contact][:phone_number].chars.last(10).join
  end

  def contact
    @message[:message][:contact]
  end

  def text
    @message[:message][:text]
  end

  def from
    @message[:message][:from]
  end

  def chat_id
    @message[:message][:from][:id]
  end

  def message_
    @message.require(:message).permit!
  end

end