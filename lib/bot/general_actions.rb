require 'telegram/bot'

class GeneralActions
  attr_reader :user, :state, :api

  def initialize(user, state)
    @user = user
    token = Rails.application.secrets.bot_token
    @api = ::Telegram::Bot::Api.new(token)
    @state = state
  end

  def back_to_menu
    @state['state'] = 1
    @user.set_user_state (@state.except 'plan_name', 'notification_id', 'question_id')
  end

  def back_to_menu_with_menu
    back_to_menu
    keyboard = GeneralActions.custom_keyboard ['Attivita', 'Feedback', 'Consigli', 'Messaggi']
    @api.call('sendMessage', chat_id: @user.telegram_id,
              text: 'Scegli con cosa vuoi continuare.', reply_markup: keyboard)
  end

  def clean_state
    @user.set_user_state (@state.except 'plan_name', 'notification_id', 'question_id')
    @user.save
    @user
  end

  def set_state(state)
    @state['state'] = state
    @user.set_user_state @state
    @user
  end

  def send_reply(reply)
    send_chat_action 'typing'
    @api.call('sendMessage', chat_id: @user.telegram_id, text: reply)
  end

  def send_reply_with_keyboard(reply, keyboard)
    @api.call('sendMessage', chat_id: @user.telegram_id, text: reply, reply_markup: keyboard)
  end

  def set_plan_name(plan_name)
    @state['plan_name'] = plan_name
    @user.set_user_state @state
  end

  def send_chat_action(action)
    @api.call('sendChatAction', chat_id: @user.telegram_id, action: action)
  end

  def send_plans_details(delivered_plans)
    send_reply "#{@user.last_name} ti sto inviando un documento che contiene tutti i dettagli relativi alle attivita' che hai da fare. Leggilo con attenzione!"
    send_chat_action 'upload_document'

    controller = UsersController.new
    controller.instance_variable_set(:'@plans', delivered_plans)
    doc_name = "#{@user.id}-#{user.first_name}#{user.last_name}-plans.pdf"

    pdf = WickedPdf.new.pdf_from_string(
        controller.render_to_string('users/user_plans', layout: 'layouts/pdf.html'),
        dpi: '250',
        # orientation: 'Landscape',
        viewport: '1280x1024',
        footer: { right: '[page] of [topage]'}
    )
    save_path = Rails.root.join('pdfs',doc_name)
    File.open(save_path, 'wb') do |file|
      file << pdf
    end

    send_doc "pdfs/#{doc_name}"
  end

  def send_feedback_details(plans)
    send_reply "#{@user.last_name} ti sto inviando un documento nel quale ci sono tutti i dettagli relativi al feedback che devi fornire fino ad oggi! Leggilo con Attenzione"
    send_chat_action 'upload_document'

    controller = UsersController.new
    controller.instance_variable_set(:'@plans', plans)
    doc_name = "#{@user.id}-#{user.first_name}#{user.last_name}-feedbacks.pdf"


    pdf = WickedPdf.new.pdf_from_string(
        controller.render_to_string('users/user_feedbacks', layout: 'layouts/pdf.html'),
        dpi: '250',
        # orientation: 'Landscape',
        viewport: '1280x1024',
        footer: { right: '[page] of [topage]'}
    )
    save_path = Rails.root.join('pdfs',doc_name)
    File.open(save_path, 'wb') do |file|
      file << pdf
    end

    send_doc "pdfs/#{doc_name}"
  end

  def plans_needing_feedback
    Plan.joins(plannings: :notifications).where('notifications.date<=? AND notifications.done=? AND plans.delivered=? AND plans.user_id=?', Date.today, 0, 1, @user.id).uniq
  end


  def send_doc(file_path)
    @api.call('sendDocument', chat_id: @user.telegram_id,
              document: Faraday::UploadIO.new(file_path, 'pdf'))
  end

  # static methods

  def self.menu_buttons
    %w[Attivita Feedback Tips Messaggi]
  end

  def self.answers_from_question(question)
    question.answers.map(&:text)
  end

  def self.plans_names(delivered_plans)
    delivered_plans.map(&:name).push('Ulteriori Dettagli').push('Torna al Menu')
  end

  def self.custom_keyboard(keyboard_values)
    kb = GeneralActions.slice_keyboard keyboard_values
    Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb, one_time_keyboard: true)
  end

  def self.slice_keyboard(values)
    values.length >= 4 ? values.each_slice(2).to_a : values
  end

  def self.menu_keyboard
    custom_keyboard menu_buttons
  end

end
