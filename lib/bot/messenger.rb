require 'bot/general'
require './lib/modules/communicator'

class Messenger
  attr_reader :user

  def initialize(user, state)
    @user = user
    @state = state
  end

  def inform
    messages = latest_coach_messages
    forward messages # that is, forward to the coach
  end

  def register_patient_response(response)
    Chat.create(user_id: @user.id, coach_user_id: @user.coach_user.id, text: response, direction: true)
    communicator = Communicator.new
    communicator.communicate_new_message(@user)
    actuator = GeneralActions.new(@user, @state)
    actuator.send_reply_with_keyboard("Il tuo messaggio è stato inviato al coach #{@user.coach_user.first_name} #{@user.coach_user.last_name}👍. Ti notificheremo se ci dovessero essere nuovi messaggi 😉.",
                                      GeneralActions.menu_keyboard)
  end

  def messages_present?
    messages = latest_coach_messages
    messages.empty? ? false : true
  end

  def inform_no_messages
    actuator = GeneralActions.new(@user, @state)
    actuator.send_reply_with_keyboard('Non hai nessun messaggio in attesa di una risposta❗.', GeneralActions.menu_keyboard)
  end

  def send_menu
    actuator = GeneralActions.new(@user, @state)
    actuator.send_reply_with_keyboard('Va bene puoi rispondere in un altro momento se vuoi😊.', GeneralActions.menu_keyboard)
  end

  private

  def latest_coach_messages
    date = last_user_msg_date
    if date.nil?
      Chat.where(:user_id => @user.id)
    else
      Chat.where('user_id = ? AND direction = ? AND created_at > ?', @user.id, false, date)
    end
  end

  def last_user_msg_date
    last_user_msg = Chat.where(:user_id => @user.id, :direction => true).last
    last_user_msg.nil? ? nil : last_user_msg.created_at
  end

  def forward messages
    actuator = GeneralActions.new(@user, @state)
    actuator.send_reply "Il medico #{@user.coach_user.first_name} #{@user.coach_user.last_name} che ti segue ti ha inviato i seguenti messaggi:"

    messages.find_each do |message|
      actuator.send_reply "#{message.created_at.strftime('%d.%m.%Y - %H:%M')} \n\t #{message.text}"
    end

    actuator.send_reply_with_keyboard("\nPer rispondere ai messaggi ti basta inserire la tua risposta e inviarla👇. \nFai attenzione che puoi rispondere una sola volta a tutti i messaggi❗.\nSe non vuoi ripondere ora puoi tornare al menu con il bottone [🔄 Rispondi più tardi] e rispondere più tardi",
                                      GeneralActions.custom_keyboard(['🔄 Rispondi più tardi']))

  end
end