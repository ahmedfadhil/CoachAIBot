require 'telegram/bot'

class GeneralActions
  attr_reader :user, :state, :api

  def initialize(user, state)
    @user = user
    token = Rails.application.secrets.bot_token
    @api = ::Telegram::Bot::Api.new(token)
    @state = state
  end

  def back_to_menu_with_menu
    @api.call('sendMessage', chat_id: @user.telegram_id,
              text: "Va bene #{@user.last_name}. Quando avrai piu' tempo torna in questa sezione.", reply_markup: GeneralActions.menu_keyboard)
  end

  def send_reply(reply)
    send_chat_action 'typing'
    @api.call('sendMessage', chat_id: @user.telegram_id, text: reply)
  end

  def send_reply_with_keyboard(reply, keyboard)
		@api.call('sendMessage', chat_id: @user.telegram_id, text: reply, reply_markup: keyboard)
  end

	def send_reply_with_keyboard_hash(reply, keyboard)
		answer = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: keyboard, one_time_keyboard: true)
    @api.call('sendMessage', chat_id: @user.telegram_id, text: reply, reply_markup: answer)
	end


  def send_chat_action(action)
    @api.call('sendChatAction', chat_id: @user.telegram_id, action: action)
  end

  def send_plans_details(delivered_plans)
    send_reply "#{@user.last_name} ti sto inviando un documento che contiene tutti i dettagli relativi alle attivita' che hai da fare."
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
    send_reply_with_keyboard 'Leggilo con attenzione!', GeneralActions.menu_keyboard
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
    @api.call('sendDocument', chat_id: @user.telegram_id, document: Faraday::UploadIO.new(file_path, 'pdf'))
  end

  ######################
  # FOR QUESTIONNAIRES #
  ######################

  def inform_no_questionnaires
    send_chat_action 'typing'
    reply = "Non hai Questionari da completare oggi! Torna piu' tardi per ricontrollare."

    @api.call('sendMessage', chat_id: @user.telegram_id, text: reply, reply_markup: GeneralActions.menu_keyboard)
  end

  def inform_no_action_received
    reply = 'Per favore usa i bottoni per interagire con il sistema.'
    send_reply_with_keyboard reply, GeneralActions.menu_keyboard
  end


  def error(chat_id)
    send_chat_action 'typing'
    @api.call('sendMessage', chat_id: chat_id,
              text: 'Errore Server, ci scusiamo per il disagio. La preghiamo di riprovare dopo.')
  end

  def send_questionnaires(questionnaires)
    # first lets save questionnaire list in bot command_data
    list = questionnaires.map(&:title)
    bot_command_data = {'questionnaires' => list}
    save_bot_command_data(bot_command_data)

    reply1 = "I questionari che hai da fare sono: \n\t-#{list.join("\n\t-")}"
    reply2 = 'Scegli un questionario per rispondere alle domande.'

    # then send bot's answer to patient
    send_reply reply1
    send_reply_with_keyboard reply2,
                             GeneralActions.custom_keyboard(list.push(back_button_text))
  end

  def inform_wrong_questionnaire(text)
    bot_command_data = JSON.parse(BotCommand.where(user: @user).last.data)

    reply1 = "Oups! '#{text}' non e' il titolo di nessun questionario che hai da fare."
    reply2 = "I questionari che hai da fare sono: \n\t-#{bot_command_data['questionnaires'].join("\n\t-")} \n Scegli uno dei questionari indicati per rispondere alle domande."

    send_reply reply1
    send_reply_with_keyboard reply2,
                             GeneralActions.custom_keyboard(bot_command_data['questionnaires'].push(back_button_text))
  end

  def ask_question(question, invitation)
    # first lets save question data invitation on bot_command_data
    bot_command_data = JSON.parse(BotCommand.where(user: @user).last.data)
    questionnaire = question.questionnaire
    bot_command_data['responding'] = {'question_id' => question.id,
                                      'invitation_id' => invitation.id,
                                      'questionnaire_id' => questionnaire.id}
    save_bot_command_data(bot_command_data)
    options = question.options.map(&:text)
    reply = question.text

    send_reply_with_keyboard reply, GeneralActions.custom_keyboard(options.push(back_button_text))
  end

  def inform_wrong_response
    reply = 'Hai scelto un opzione non disponibile per questa domanda. Per favore scegli una delle opzioni disponibili.'
    send_reply reply
  end

  def send_response_saved
    send_reply 'Risposta Salvata!'
  end

  def send_questionnaire_finished
    bot_command_data = JSON.parse(BotCommand.where(user: @user).last.data)
    questionnaire = Questionnaire.find(bot_command_data['responding']['questionnaire_id'])
    reply = "Hai finito il questionario '#{questionnaire.title}'. Per controllare se ci sono altri questionari vai alla sezione QUESTIONARI."
    send_reply_with_keyboard reply,
                             GeneralActions.custom_keyboard(GeneralActions.menu_buttons)
  end

  # data.class has to be Hash
  def save_bot_command_data(data)
    BotCommand.create(user_id: @user.id, data: data.to_json)
  end

  def back_button_text
    'Rispondi piu\' tardi/Torna al Menu'
  end

  #######################

  # static methods

  def self.menu_buttons
    %w[Attivita Feedback Questionari Messaggi Allenamenti]
  end

  def self.answers_from_question(question)
    question.answers.map(&:text)
  end

  def self.plans_names(delivered_plans)
    delivered_plans.map(&:name).push('Ulteriori Dettagli').push('Torna al Menu')
  end

  def self.custom_keyboard(keyboard_values)
    kb = GeneralActions.slice_keyboard keyboard_values
    k = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb, one_time_keyboard: true)
    k
  end

  def self.slice_keyboard(values)
    values.length >= 4 ? values.each_slice(2).to_a : values
  end

  def self.menu_keyboard
    custom_keyboard GeneralActions.menu_buttons
  end

end
