require "#{Rails.root}/lib/bot_v2/general"

class QuestionnaireManager
  attr_reader :user, :bot_command_data

  def initialize(user, bot_command_data)
    @user = user
    @bot_command_data = bot_command_data
  end

  def restore_last_question
    manager = GeneralActions.new(@user, nil)
    reply1 = "OK #{@user.first_name}, Ti rifaccio la domanda precedente!"

    manager.send_reply(reply1)

    invitation = Invitation.find(@bot_command_data['recover_data']['invitation_id'])
    question = QuestionnaireQuestion.find(@bot_command_data['recover_data']['question_id'])
    answer = QuestionnaireAnswer.find(@bot_command_data['recover_data']['answer_id'])
    answer.destroy!

    ask(question, invitation, false)
  end

  def ask_confirmation(response)
    actuator = GeneralActions.new(@user, nil)
    @bot_command_data['recover_data'] = {'question_id' => @bot_command_data['responding']['question_id'],
                                         'invitation_id' => @bot_command_data['responding']['invitation_id'],
                                         'questionnaire_id' => @bot_command_data['responding']['questionnaire_id'],
                                         'response' => response}
    actuator.save_bot_command_data(@bot_command_data)
    reply = "Confermi l'ultima domanda?"
    actuator.send_reply_with_keyboard reply, GeneralActions.custom_keyboard(['Si', 'No'])
  end

  def is_last_questionnaire?
    Invitation.where(user: @user, completed: true).size == Invitation.where(user: @user).size-1 ? true : false
  end

  def is_last_question?
    questionnaire = Questionnaire.find(@bot_command_data['responding']['questionnaire_id'])
    invitation = Invitation.find(@bot_command_data['responding']['invitation_id'])
    if questionnaire.questionnaire_questions.count-1 == invitation.questionnaire_answers.distinct.count(:questionnaire_question_id)
      true
    else
      false
    end
  end

  def ask_last_question_again(back_button)
    question = QuestionnaireQuestion.find(@bot_command_data['responding']['question_id'])
    ask_question(question.questionnaire.title, back_button)
  end

  def ask_again_after_negative_confirmation
    GeneralActions.new(@user, nil).send_reply("Ok #{@user.last_name}, ti rifaccio l'ultima domanda.")
    question = QuestionnaireQuestion.find(@bot_command_data['recover_data']['question_id'])
    ask_question(question.questionnaire.title, false)
  end

  def register_response(response)
    answer = QuestionnaireAnswer.create(invitation_id: @bot_command_data['responding']['invitation_id'], questionnaire_question_id: @bot_command_data['responding']['question_id'], text: response)
    actuator = GeneralActions.new(@user, nil)
    @bot_command_data['recover_data'] = {'question_id' => @bot_command_data['responding']['question_id'],
                                         'invitation_id' => @bot_command_data['responding']['invitation_id'],
                                         'questionnaire_id' => @bot_command_data['responding']['questionnaire_id'],
                                         'answer_id' => answer.id,
                                         'response' => response}
    actuator.save_bot_command_data(@bot_command_data)
  end

  def is_response?(response)
    question = QuestionnaireQuestion.find(@bot_command_data['responding']['question_id'])
    options = question.options.map(&:text)
    options.include?(response) ? true : false
  end

  def ask_question(q_name, back_button)
    invitation = Invitation.joins(:questionnaire).where('questionnaires.title = ? AND invitations.completed = ? AND invitations.user_id = ?', q_name, false, @user.id).first
    questionnaire = invitation.questionnaire
    question = questionnaire.questionnaire_questions[invitation.questionnaire_answers.distinct.count(:questionnaire_question_id)]
    ask(question, invitation, back_button)
  end

  def questionnaire_is_not_finished?(q_name)
    Questionnaire.joins(:invitations).where('questionnaires.title = ? AND invitations.completed = ? AND invitations.user_id = ?', q_name, true, @user.id).empty?
  end

  def has_questionnaires?
    !Invitation.where(user: @user, completed: false).empty?
  end

  def show_questionnaires
    questionnaires = Questionnaire.joins(:invitations).where('invitations.completed = ? AND invitations.user_id = ?', false, @user.id)
    send_questionnaires(questionnaires)
  end

  def ask(question, invitation, back_button)
    # first lets save question data invitation on bot_command_data
    actuator = GeneralActions.new(@user, nil)
    questionnaire = question.questionnaire
    @bot_command_data['responding'] = {'question_id' => question.id,
                                       'invitation_id' => invitation.id,
                                       'questionnaire_id' => questionnaire.id}
    actuator.save_bot_command_data(@bot_command_data)
    options = question.options.map(&:text)
    if back_button
      options.push('Torna alla domanda precedente')
    end
    options.push(GeneralActions.back_button_text)
    reply = question.text

    actuator.send_reply_with_keyboard reply, GeneralActions.custom_keyboard(options)
  end

  def send_questionnaires(questionnaires)
    # first lets save questionnaire list in bot command_data
    list = questionnaires.map(&:title)
    bot_command_data = {'questionnaires' => list}
    actuator = GeneralActions.new(@user, nil)
    actuator.save_bot_command_data(bot_command_data)

    reply1 = "I questionari che hai da fare sono: \n\t-#{list.join("\n\t-")}"
    reply2 = "Quale questionario vuoi compilare?"

    # then send bot's answer to patient
    actuator.send_reply reply1
    actuator.send_reply_with_keyboard reply2, GeneralActions.custom_keyboard(list.push(GeneralActions.back_button_text))
  end

  def inform_no_questionnaires
    reply = "Non hai Questionari da completare oggi! Torna piu' tardi per ricontrollare."
    GeneralActions.new(@user,nil).send_reply_with_keyboard(reply, GeneralActions.menu_keyboard)
  end

  def inform_no_action_received
    reply = 'Per favore usa i bottoni per interagire con il sistema.'
    GeneralActions.new(@user,nil).send_reply_with_keyboard(reply, GeneralActions.menu_keyboard)
  end


  def inform_wrong_questionnaire(text)
    reply1 = "Oups! '#{text}' non e' il titolo di un questionario che hai da fare."
    reply2 = "I questionari che hai da fare sono: \n\t-#{@bot_command_data['questionnaires'].join("\n\t-")} \n Scegli uno dei questionari indicati per rispondere alle domande."
    actuator = GeneralActions.new(@user,nil)
    actuator.send_reply(reply1)
    actuator.send_reply_with_keyboard(reply2, GeneralActions.custom_keyboard(@bot_command_data['questionnaires'].push(GeneralActions.back_button_text)))
  end


  def inform_wrong_response
    reply = 'Hai scelto un opzione non disponibile per questa domanda. Per favore scegli una delle opzioni disponibili.'
    GeneralActions.new(@user,nil).send_reply reply
  end

  def send_response_saved
    GeneralActions.new(@user,nil).send_reply 'Risposta Salvata!'
  end

  def send_questionnaire_finished
    bot_command_data = JSON.parse(BotCommand.where(user: @user).last.data)
    questionnaire = Questionnaire.find(bot_command_data['responding']['questionnaire_id'])
    reply = "Hai finito il questionario '#{questionnaire.title}'."
    GeneralActions.new(@user, nil).send_reply reply
    show_questionnaires
  end

  def send_menu
    reply = "OK #{@user.last_name}, proseguiamo piu tardi! \nA presto!"
    GeneralActions.new(@user, nil).send_reply_with_keyboard reply, GeneralActions.menu_keyboard
  end

  def send_profiling_finished
    reply1 = "Hai finito di compilare l'ultimo questionario!"
    reply2 = "Sulla base delle tue domande e di altre informazioni sul tuo stato di salute uno specialista che ti segue definirà un piano il quale conterrà delle attività che sarai invitato a seguire secondo le indicazioni che riceverai.\n\n"
    + "Quando verrà definito un piano per te verrai notificato e potrai accedere al piano attraverso il bottone ATTIVITÀ. Inoltre potrai richiedere di scaricare in formato PDF il documento contenente tutti i dettagli relativi al piano.\n\n"
    reply3 = "Rimani in attesa del piano! A presto #{@user.last_name}"
    GeneralActions.new(@user, nil).send_reply(reply1)
    GeneralActions.new(@user, nil).send_reply(reply2)
    GeneralActions.new(@user, nil).send_reply_with_keyboard(reply3, GeneralActions.menu_keyboard)
  end

end