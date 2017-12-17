require 'bot/general_actions'
require './lib/modules/communicator'

class Messenger2
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def inform
    messages = latest_coach_messages
    if messages.empty?
      no_messages
    else
      forward messages # that is, forward to the coach
    end
  end

  def register_patient_response(response)
    Chat.create(user_id: @user.id, coach_user_id: @user.coach_user.id, text: response, direction: true)
    communicator = Communicator.new
    communicator.communicate_new_message(@user)
    actuator = GeneralActions.new(@user, @state)
    actuator.send_reply 'Il tuo messaggio e\' stato inviato al coach. Ti notificheremo se ci dovessero essere nuovi messaggi per te.'
    actuator.back_to_menu_with_menu
  end

  private
  def last_user_msg_date
    last_user_msg = Chat.where(:user_id => @user.id, :direction => true).last
    last_user_msg.nil? ? nil : last_user_msg.created_at
  end

  def latest_coach_messages
    date = last_user_msg_date
    if date.nil?
      Chat.where(:user_id => @user.id)
    else
      Chat.where('user_id = ? AND direction = ? AND created_at > ?', @user.id, false, date)
    end
  end

  def no_messages
    actuator = GeneralActions.new(@user, @state)
    actuator.send_reply 'Non hai nessun messaggio in attesa di essere letto.'
    actuator.back_to_menu_with_menu
  end

  def forward messages
    actuator = GeneralActions.new(@user, @state)
    actuator.set_state 3
    actuator.send_reply 'Il medico che ti segue ti ha inviato i seguenti messaggi:'

    messages.find_each do |message|
      actuator.send_reply "#{message.created_at.strftime('%d.%m.%Y - %H:%M')} \n\t #{message.text}"
    end

    actuator.send_reply_with_keyboard("Per rispondere ai messaggi ti basta inserire la tua risposta e inviarla. Fai attenzione che puoi rispondere una sola volta a tutti i messaggi.\nSe non vuoi ripondere ora puoi tornare al menu con il bottone 'Torna al Menu' e rispondere piu tardi",
                                      GeneralActions.custom_keyboard(['Rispondi piu\' tardi/Torna al Menu']))

  end
end