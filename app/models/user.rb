require "#{Rails.root}/lib/bot_v2/messenger"
require "#{Rails.root}/lib/bot_v2/activity_informer"
require "#{Rails.root}/lib/bot_v2/feedback_manager"
require "#{Rails.root}/lib/bot_v2/questionnaire_manager"
require "#{Rails.root}/lib/bot_v2/general"
require "#{Rails.root}/lib/modules/features_manager"

class User < ApplicationRecord
  has_many :communications, dependent: :destroy
  has_many :chats, dependent: :destroy
	has_many :daily_logs, dependent: :destroy
  has_many :plans, dependent: :destroy
  belongs_to :coach_user, optional: true
  has_many :invitations, dependent: :destroy
  has_many :bot_commands, dependent: :destroy

  validates :telegram_id, uniqueness: true, allow_nil: true
  validates_uniqueness_of :email, message: 'Email in uso. Scegli altra email.'
  validates_uniqueness_of :cellphone, message: 'Cellulare in uso. Scegli un altro numero di cellulare.'
  validates :first_name, presence: { message: 'Inserisci nome.' }, length: { maximum: 50 }
  validates :last_name, presence: { message: 'Inserisci cognome.' }, length: { maximum: 50 }
  validates :cellphone, presence: { message: 'Inserisci numero cellulare.' }, length: { maximum: 25, message: 'Numero Cellulare troppo lungo. Max 25.' }
  validates :age, presence: { message: 'Inserisci eta\'.' }
  validate :age_has_to_be_positive

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: { message: "Email non puo' essere vuota." }, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX, message: "Formato dell'email non valido. Usare email della forma esempio@myemail.org" }

  def age_has_to_be_positive
    unless self.age.nil?
      if self.age < 0
        errors.add(:user, "L'eta' del paziente non puo' essere negativa e nemmeno vuota!")
      end
    end
  end

  def profiled?
    Invitation.where('invitations.completed = ? AND invitations.user_id = ?', false, self.id).empty?
  end

  def archived?
    self.state == 'ARCHIVED'
  end

  def has_delivered_plans?
    self.plans.where(:delivered => 1).count > 0
  end

  include AASM # Act As State Machine

  # default column: aasm_state
  # no direct assignment to aasm_state
  # return false instead of exceptions
  aasm  :whiny_transitions => false do

    ########## States ##############################################
    state :idle, :initial => true
    state :messages, :activities, :questionnaires, :responding, :confirmation, :feedback_plans, :feedback_activities, :feedbacking, :recover, :help
    ###################################################################

=begin
    event :give_help do
      transitions :from => :idle, :to => :help,
                  :after => :send_help_first_msg
    end
    event :choose_faq do
      transitions :from => :help, :to => :idle,
                  :after => Proc.new {|*args| redirect_to_apiAI(*args)}
    end
=end

    ########## Feedback Events ##############################################
    event :show_plans_to_feedback do
      transitions :from => :idle, :to => :feedback_plans,
                  :after => :send_plans_to_feedback,
                  :guard => :has_plans_to_feedback?
      transitions :from => :idle, :to => :idle,
                  :after => :inform_no_plans_to_feedback
    end

    event :show_activities_to_feedback do
      transitions :from => :feedback_plans, :to => :feedback_activities,
                  :after => Proc.new {|*args| send_activities_that_need_feedback(*args)},
                  :guard => Proc.new {|*args| valid_plan_name?(*args)}
      transitions :from => :feedback_plans, :to => :feedback_plans,
                  :after => :inform_wrong_plan_name
    end

    event :start_feedbacking do
      transitions :from => :feedback_activities, :to => :feedbacking,
                  :after => Proc.new {|*args| start_asking(*args)},
                  :guard => Proc.new {|*args| valid_activity_name?(*args)}
      transitions :from => :feedback_activities, :to => :feedback_activities,
                  :after => :inform_wrong_activity_name
    end

    event :feedback do
      transitions :from => :feedbacking, :to => :idle,
                  :after => Proc.new {|*args| register_last_feedback(*args)},
                  :guard => Proc.new {|*args| is_last_feedback_and_last_question?(*args)}
      transitions :from => :feedbacking, :to => :feedback_plans,
                  :after => Proc.new {|*args| register_last_answer(*args)},
                  :guard => Proc.new {|*args| is_last_question_and_is_answer?(*args)}
      transitions :from => :feedbacking, :to => :feedbacking,
                  :after => Proc.new {|*args| register_answer_and_continue(*args)},
                  :guard => Proc.new {|*args| is_answer?(*args)}
      transitions :from => :feedbacking, :to => :feedbacking,
                  :after => :inform_wrong_answer
    end
    ###################################################################



    ########## Activities Events ###########################################
    event :get_activities do
      transitions :from => :idle, :to => :activities,
                  :after => :send_activities,
                  :guard => :activities_present?
      transitions :from => :idle, :to => :idle,
                  :after => :inform_no_activities
    end
    ###################################################################



    ########## Messages Events #############################################
    event :get_messages do
      transitions :from => :idle, :to => :messages,
                  :after => :send_messages,
                  :guard => :messages_present?
      transitions :from => :idle, :to => :idle,
                  :after => :inform_no_messages
    end

    event :respond do
      transitions :from => :messages, :to => :idle,
                  :after => Proc.new {|*args| register_patient_response(*args) }
    end
    ###################################################################



    ########## Questionnaires Events ####################################
    event :start_questionnaires do
      transitions :from => :idle, :to => :questionnaires,
                  :after => :show_questionnaires,
                  :guard => :has_questionnaires?
      transitions :from => :idle, :to => :idle,
                  :after => :inform_no_questionnaires
    end

    event :start_responding do
      transitions :from => :questionnaires, :to => :responding,
                  :after => Proc.new {|*args| ask_question(*args)},
                  :guard => Proc.new {|*args| questionnaire_is_not_finished?(*args)}
      transitions :from => :questionnaires, :to => :questionnaires,
                  :after => Proc.new {|*args| inform_wrong_questionnaire(*args)}
    end

=begin
    event :respond_questionnaire do
      transitions :from => :responding, :to => :confirmation,
                  :after => Proc.new {|*args| register_last_questionnaire_response(*args)},
                  :guard => Proc.new {|*args| is_last_question_and_last_questionnaire?(*args)}
      transitions :from => :responding, :to => :confirmation,
                  :after => Proc.new {|*args| register_last_response(*args)},
                  :guard => Proc.new {|*args| is_last_question_and_is_response?(*args)}
      transitions :from => :responding, :to => :responding,
                  :after => Proc.new {|*args| register_response(*args)},
                  :guard => Proc.new {|*args| is_response?(*args)}
      transitions :from => :responding, :to => :responding,
                  :after => :ask_last_question_again
    end
=end

    event :respond_questionnaire do
      transitions :from => :responding, :to => :confirmation,
                  :after => Proc.new {|*args| ask_confirmation(*args)},
                  :guard => Proc.new {|*args| is_last_question_and_is_response?(*args)}
      transitions :from => :responding, :to => :responding,
                  :after => Proc.new {|*args| register_response(*args)},
                  :guard => Proc.new {|*args| is_response?(*args)}
      transitions :from => :responding, :to => :responding,
                  :after => :ask_last_question_again
    end

    event :cancel_last_answer do
      transitions :from => :responding, :to => :responding,
                  :after => :restore_last_question
    end

    event :confirm do
      transitions :from => :confirmation, :to => :idle,
                  :after => :register_last_questionnaire_response,
                  :guard => :is_last_questionnaire?
      transitions :from => :confirmation, :to => :questionnaires,
                  :after => :register_last_response
    end

    event :cancel_confirmation do
      transitions :from => :confirmation, :to => :responding,
                  :after => :ask_again_after_negative_confirmation
    end


    ###################################################################



    ########## Cancel from each state to idle ########################
    event :cancel do
      transitions :from => :activities, :to => :idle,
                  :after => :send_menu_from_activities
      transitions :from => :messages, :to => :idle,
                  :after => :send_menu_from_messages

      transitions :from => :questionnaires, :to => :idle,
                  :after => :send_menu_from_questionnaires
      transitions :from => :responding, :to => :idle,
                  :after => :send_menu_from_questionnaires
      transitions :from => :confirmation, :to => :idle,
                  :after => :send_menu_from_questionnaires

      transitions :from => :responding, :to => :idle,
                  :after => :send_menu_from_questionnaires
      transitions :from => :feedback_plans, :to => :idle,
                  :after => :send_menu_from_feedbacks
      transitions :from => :feedback_activities, :to => :idle,
                  :after => :send_menu_from_feedbacks
      transitions :from => :feedbacking, :to => :idle,
                  :after => :send_menu_from_feedbacks
      transitions :from => :confirm, :to => :idle,
                  :after => :send_menu_from_feedbacks
    end
    ###################################################################



    ########## Send Details for Activities and Feedbacks ############
    event :get_details do
      transitions :from => :activities, :to => :idle,
                  :after => :send_activities_details
      transitions :from => :feedback_plans, :to => :feedback_plans,
                  :after => :send_feedbacks_details
    end

    event :no_action do
      transitions :from => :idle, :to => :idle,
                  :after => :send_no_action_received
    end
    ###################################################################

  end


  private

  ############### Questionnaires Methods ######################################################################################

  def restore_last_question
    QuestionnaireManager.new(self, command_data).restore_last_question
  end

  def ask_confirmation(response)
    QuestionnaireManager.new(self, command_data).ask_confirmation(response)
  end

  def register_last_questionnaire_response
    bot_command_data = command_data
    manager = QuestionnaireManager.new(self, bot_command_data)
    manager.register_response(bot_command_data['recover_data']['response'])
    invitation = Invitation.find(bot_command_data['recover_data']['invitation_id'])
    invitation.completed = true
    invitation.save
    manager.send_profiling_finished
    questionnaire = Questionnaire.find(bot_command_data['recover_data']['questionnaire_id'])
    questionnaire.completed = true
    questionnaire.save!
    features_manager = FeaturesManager.new
    features_manager.communicate_profiling_done! self
    features_manager.save_features_to_csv self
    system 'rake python_clustering &'
  end

  def is_last_question_and_last_questionnaire?
    (QuestionnaireManager.new(self, command_data).is_last_questionnaire? && is_last_question_and_is_response?) ? true : false
  end

  def is_last_questionnaire?
    QuestionnaireManager.new(self, command_data).is_last_questionnaire?
  end

  def register_last_response
    bot_command_data = command_data
    response = bot_command_data['recover_data']['response']
    manager = QuestionnaireManager.new(self, bot_command_data)
    manager.register_response(response)
    invitation = Invitation.find(bot_command_data['recover_data']['invitation_id'])
    invitation.completed = true
    invitation.save
    manager.send_questionnaire_finished
    questionnaire = Questionnaire.find(bot_command_data['recover_data']['questionnaire_id'])
    questionnaire.completed = true
    questionnaire.save!
  end

  def is_last_question_and_is_response?(response)
    (is_response?(response) && QuestionnaireManager.new(self, command_data).is_last_question?) ? true : false
  end

  def ask_next_question
    bot_command_data = command_data
    QuestionnaireManager.new(self, bot_command_data).ask_question(Questionnaire.find(bot_command_data['responding']['questionnaire_id']).title, true)
  end

  def ask_again_after_negative_confirmation
    QuestionnaireManager.new(self, command_data).ask_again_after_negative_confirmation
  end

  def ask_last_question_again
    manager = QuestionnaireManager.new(self, command_data)
    manager.inform_wrong_response
    manager.ask_last_question_again(false)
  end

  def register_response(response)
    QuestionnaireManager.new(self, command_data).register_response(response)
    ask_next_question
  end

  def is_response?(response)
    QuestionnaireManager.new(self, command_data).is_response?(response)
  end

  def inform_wrong_questionnaire(text)
    QuestionnaireManager.new(self, nil).inform_wrong_questionnaire(text)
  end

  def ask_question(questionnaire)
    QuestionnaireManager.new(self, command_data).ask_question(questionnaire, false)
  end

  def questionnaire_is_not_finished?(questionnaire)
    QuestionnaireManager.new(self, command_data).questionnaire_is_not_finished?(questionnaire)
  end

  def show_questionnaires
    QuestionnaireManager.new(self, command_data).show_questionnaires
  end

  def has_questionnaires?
    QuestionnaireManager.new(self, command_data).has_questionnaires?
  end

  def send_no_action_received
    QuestionnaireManager.new(self, command_data).inform_no_action_received
  end

  def inform_no_questionnaires
    QuestionnaireManager.new(self, command_data).inform_no_questionnaires
  end

  def send_menu_from_questionnaires
    QuestionnaireManager.new(self, command_data).send_menu
  end

  ####################################################################################################################################

  ########## Feedback Methods ##################################################################################

  def is_last_feedback_and_last_question?(answer)
    manager = FeedbackManager.new(self)
    (manager.is_answer?(answer) && manager.is_last_question? && manager.is_last_feedback?) ? true : false
  end

  def register_last_feedback(answer)
    manager = FeedbackManager.new(self)
    manager.register_last_answer(answer)
    actuator = GeneralActions.new(self, nil)
    actuator.send_reply_with_keyboard("Non hai piu' feedback da dare per oggi! Prosegui con le attivita'.", GeneralActions.menu_keyboard)
  end

  def inform_wrong_answer
    FeedbackManager.new(self).inform_wrong_answer
  end

  def register_last_answer(answer)
    manager = FeedbackManager.new(self)
    manager.register_last_answer(answer)
    actuator = GeneralActions.new(self, nil)
    actuator.send_reply('Con che piano vuoi proseguire il feedback?')
    manager.send_plans_to_feedback
  end

  def is_last_question_and_is_answer?(answer)
    manager = FeedbackManager.new(self)
    if manager.is_answer?(answer) && manager.is_last_question?
      true
    else
      false
    end
  end

  def register_answer_and_continue(answer)
    FeedbackManager.new(self).register_answer_and_continue(answer)
  end

  def is_answer?(answer)
    FeedbackManager.new(self).is_answer?(answer)
  end

  def inform_wrong_activity_name
    FeedbackManager.new(self).inform_wrong_activity
  end

  def start_asking(activity_name)
    FeedbackManager.new(self).ask(activity_name)
  end

  def valid_activity_name?(activity_name)
    FeedbackManager.new(self).valid_activity_name?(activity_name)
  end

  def inform_wrong_plan_name
    FeedbackManager.new(self).inform_wrong_plan
  end

  def send_activities_that_need_feedback(plan_name)
    FeedbackManager.new(self).send_activities_that_need_feedback(plan_name)
  end

  def valid_plan_name?(plan_name)
    FeedbackManager.new(self).valid_plan_name?(plan_name)
  end

  def inform_no_plans_to_feedback
    FeedbackManager.new(self).inform_no_plans_to_feedback
  end

  def send_plans_to_feedback
    FeedbackManager.new(self).send_plans_to_feedback
  end

  def has_plans_to_feedback?
    FeedbackManager.new(self).has_plans_to_feedback?
  end

  def send_feedbacks_details
    feedback_manager = FeedbackManager.new(self)
    feedback_manager.send_feedback_details(feedback_manager.plans_to_feedback)
    feedback_manager.send_plans_to_feedback
  end

  def send_menu_from_feedbacks
    GeneralActions.new(self, nil).back_to_menu_with_menu
  end

  #############################################################################################################################





  ############### Activities Methods ##########################################################################################
  def send_activities_details
    ActivityInformer.new(self, nil).send_details
  end

  def send_activities
    ActivityInformer.new(self, nil).send_activities
  end

  def inform_no_activities
    ActivityInformer.new(self, nil).inform_no_activities
  end

  def send_menu_from_activities
    ActivityInformer.new(self, nil).send_menu
  end

  def activities_present?
    ActivityInformer.new(self, nil).activities_present?
  end
  ###########################################################################################################################




  ############### Messages Methods ##########################################################################################
  def send_messages
    Messenger.new(self, nil).inform
  end

  def messages_present?
    Messenger.new(self, nil).messages_present?
  end

  def inform_no_messages
    Messenger.new(self, nil).inform_no_messages
  end

  def send_menu_from_messages
    Messenger.new(self, nil).send_menu
  end

  def register_patient_response(response)
    Messenger.new(self, nil).register_patient_response(response)
  end
  #############################################################################################################################




  def back_to_menu
    GeneralActions.new(self, nil).back_to_menu_with_menu
  end

  # will be called if any event fails
  def aasm_event_failed(event_name, old_state_name)
    # use custom exception/messages, report metrics, etc
  end

  def command_data
    JSON.parse(BotCommand.where(user: self).last.data)
  end
end
