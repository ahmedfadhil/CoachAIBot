require "#{Rails.root}/lib/bot_v2/general"

class QuestionnaireManager
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def is_last_question?
    bot_command_data = JSON.parse(BotCommand.where(user: @user).last.data)
    questionnaire = Questionnaire.find(bot_command_data['responding']['questionnaire_id'])
    invitation = Invitation.find(bot_command_data['responding']['invitation_id'])
    if questionnaire.questionnaire_questions.count-1 == invitation.questionnaire_answers.count
      true
    else
      false
    end
  end

  def ask_last_question_again
    bot_command_data = JSON.parse(BotCommand.where(user: @user).last.data)
    question = QuestionnaireQuestion.find(bot_command_data['responding']['question_id'])
    invitation = Invitation.find(bot_command_data['responding']['invitation_id'])
    dialog_manager = GeneralActions.new(@user, nil)
    dialog_manager.inform_wrong_response
    dialog_manager.ask_question(question, invitation)
  end

  def register_response(response)
    bot_command_data = JSON.parse(BotCommand.where(user: @user).last.data)
    QuestionnaireAnswer.create(invitation_id: bot_command_data['responding']['invitation_id'],
                  questionnaire_question_id: bot_command_data['responding']['question_id'], text: response)
    GeneralActions.new(@user, nil).send_response_saved
  end

  def is_response?(response)
    bot_command_data = JSON.parse(BotCommand.where(user: @user).last.data)
    question = QuestionnaireQuestion.find(bot_command_data['responding']['question_id'])
    options = question.options.map(&:text)
    options.include?(response) ? true : false
  end

  def ask_question(q_name)
    invitations = Invitation.where(user_id: @user.id)
    invitations.each do |invitation|
      questionnaire = Questionnaire.where(id: invitation.questionnaire_id, title: q_name).first
      unless questionnaire.nil?
        question = questionnaire.questionnaire_questions[invitation.questionnaire_answers.count]
        GeneralActions.new(@user, nil).ask_question(question, invitation)
      end
    end
  end

  def questionnaire_is_not_finished?(q_name)
    invitations = Invitation.where(user_id: @user.id)
    invitations.each do |invitation|
      questionnaire = Questionnaire.where(id: invitation.questionnaire_id, title: q_name).first
      unless questionnaire.nil?
        if invitation.questionnaire_answers.count < questionnaire.questionnaire_questions.count
          return true
        end
      end
    end
    false
  end

  def has_questionnaires?
    invitations = Invitation.where(user_id: @user.id)
    invitations.each do |invitation|
      questionnaire = Questionnaire.where(id: invitation.questionnaire_id).first
      if invitation.questionnaire_answers.count < questionnaire.questionnaire_questions.count
        return true
      end
    end
    false
  end

  def show_questionnaires
    invitations = Invitation.where(user_id: @user.id)
    questionnaires = []
    invitations.each do |invitation|
      questionnaire = Questionnaire.where(id: invitation.questionnaire_id).first
      if invitation.questionnaire_answers.count < questionnaire.questionnaire_questions.count
        questionnaires.push questionnaire
      end
    end
    GeneralActions.new(@user, nil).send_questionnaires(questionnaires)
  end
end