require "#{Rails.root}/lib/bot/messenger"
require "#{Rails.root}/lib/bot/activity_informer"
require "#{Rails.root}/lib/bot/feedback_manager"
require "#{Rails.root}/lib/bot/questionnaire_manager"
require "#{Rails.root}/lib/bot/general"
require "#{Rails.root}/lib/modules/features_manager"

class User < ApplicationRecord
	#has_many :communications, dependent: :destroy
	#has_many :chats, dependent: :destroy
	#has_many :daily_logs, dependent: :destroy
	#has_many :plans, dependent: :destroy
	#belongs_to :coach_user, optional: true
	#has_many :invitations, dependent: :destroy
	#has_many :bot_commands, dependent: :destroy
	has_many :objectives
	has_many :daily_logs

  has_many :communications, dependent: :destroy
  has_many :chats, dependent: :destroy
  has_many :daily_logs, dependent: :destroy
  has_many :plans, dependent: :destroy
  has_many :activities, through: :plans
  belongs_to :coach_user, optional: true
  has_many :invitations, dependent: :destroy
  has_many :bot_commands, dependent: :destroy
  has_many :questionnaires, through: :invitations, dependent: :destroy
  has_many :questionnaire_questions, through: :questionnaires, dependent: :destroy
  has_many :options, through: :questionnaire_questions, dependent: :destroy
  has_many :questionnaire_answers, through: :questionnaire_questions, dependent: :destroy

  validates :telegram_id, uniqueness: true, allow_nil: true
  validates_uniqueness_of :email, message: 'Email in uso. Scegli altra email.'
  validates_uniqueness_of :cellphone, message: 'Cellulare in uso. Scegli un altro numero di cellulare.'
  validates :first_name, presence: {message: 'Inserisci nome.'}, length: {maximum: 50}
  validates :last_name, presence: {message: 'Inserisci cognome.'}, length: {maximum: 50}
  validates :cellphone, presence: {message: 'Inserisci numero cellulare.'}, length: {maximum: 12, message: 'Numero cellulare troppo lungo. Max 12 cifre.'}
  validates :age, presence: {message: 'Inserisci età.'}, length: {maximum: 2, message: 'l età deve essere di due cifre'}
  validate :age_has_to_be_positive
  # validates :tag_list, uniqueness: true

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: {message: "Email non puo' essere vuota."}, length: {maximum: 255}, format: {with: VALID_EMAIL_REGEX, message: "Formato dell'email non valido. Usare email della forma esempio@myemail.org"}
  GenderType = ['maschio', 'femmina']
  validates_inclusion_of :gender, in: GenderType

	enum fitbit_status: {fitbit_disabled: 0, fitbit_invited: 1, fitbit_enabled: 2}
	serialize :access_token, JSON

  acts_as_taggable
  # Saving user data into a csv
  CSV_HEADER = %w[id first_name last_name email cellphone state fitbit_status age py_cluster patient_objective
gender height weight blood_type tag_list invitation_id questionnaire_id questionnaire_question_id option_id test test
 test]

  def self.to_csv
    CSV.generate do |csv|
      csv << CSV_HEADER
      all.each do |user|

        csv << [
            unless user.id?
              "null"
            end,
            unless user.first_name?
              "null"
            end,
            unless user.last_name?
              "null"
            end,
            unless user.email?
              "null"
            end,
            unless user.cellphone?
              "null"
            end,
            unless user.state?
              "null"
            end,
            unless user.fitbit_status?
              "null"
            end,
            unless user.age
              "null"
            end,
            unless user.py_cluster?
              "null"
            end,
            unless user.patient_objective?

              "null"
            end,
            unless user.gender?
              "null"
            end,
            unless user.height?
              "null"
            end,
            unless user.weight?
              "null"
            end,
            unless user.blood_type?
              "null"
            end,
            unless user.tag_list
              "null"
            end,
            "#{user.invitation_ids.join(';')}",
            "#{user.questionnaire_ids.join(';')}",
            "#{user.questionnaire_question_ids.join(';')}"


        # user.hobbies.pluck(:title).join(', ')
        ].uniq

        csv << CSV_HEADER
        user.questionnaire_questions.each do |questionnaire|
          csv << [
              "questionnaire questions #{questionnaire.text}",
              "questionnaire opt #{questionnaire.option_ids}",
              "questionnaire ans #{questionnaire.questionnaire_answer_ids}"

          ].uniq
        end

        csv << CSV_HEADER
        user.questionnaire_questions.each do |questionnaire|
          questionnaire.options.each do |op|
            csv << [
                "questionnaire options: #{op.id}",
                "questionnaire options: #{op.text}",
                "questionnaire score #{op.score}"
            ].uniq
          end
          user.questionnaire_questions.each do |questionnaire|
            questionnaire.questionnaire_answers.each do |ans|
              csv << [
                  "questionnaire answer test: #{ans.text}"
              ].uniq
            end
          end
        end
        csv << CSV_HEADER
        user.questionnaires.each do |questionnaire|
          csv << [
              "questionnaire =>#{questionnaire.title}",
              "questionnaire desc=> #{questionnaire.desc}",
              "questionnaire completed=> #{questionnaire.completed}"

          ].uniq
        end
        csv << CSV_HEADER
        user.invitations.each do |questionnaire|
          csv << [
              "invitation user =>#{questionnaire.user_id}",
              "invitation questionnarie=> #{questionnaire.questionnaire_id}",
              "questionnaire campagin=> #{questionnaire.campaign}"

          ].uniq
        end

      end
    end
  end


  #   # Saving user data into a csv
  INVI_HEADER = %w[one two three]
  CSV_HEADER = %w[id first_name last_name email cellphone state fitbit_status age py_cluster patient_objective
gender height weight blood_type tag_list]

  def to_csv
    CSV.generate do |user_csv|
      user_csv << ["Information about: #{first_name} #{last_name}"]
      user_csv << CSV_HEADER
      user_csv << [

          id do |row|
            row.id ? row.id : "Sconosciuto"
          end,
          first_name do |row|
            row.first_name ? row.first_name : "Sconosciuto"
          end,
          last_name do |row|
            row.last_name ? row.last_name : "Sconosciuto"
          end,
          email do |row|
            row.email ? row.email : "Sconosciuto"
          end,
          cellphone do |row|
            row.cellphone ? row.cellphone : "Sconosciuto"
          end,
          state do |row|
            row.state ? row.state : "Sconosciuto"
          end,
          fitbit_status do |row|
            row.fitbit_status ? row.fitbit_status : "Sconosciuto"
          end,
          age do |row|
            row.age ? row.age : "Sconosciuto"
          end,

          py_cluster do |row|
            row.py_cluster ? row.py_cluster : "Sconosciuto"
          end,
          patient_objective do |row|
            row.patient_objective ? row.patient_objective : "Sconosciuto"
          end,
          gender do |row|
            row.gender ? row.gender : "Sconosciuto"
          end,
          height do |row|
            row.height ? row.height : "Sconosciuto"
          end,
          weight do |row|
            row.weight ? row.weight : "Sconosciuto"
          end,
          blood_type do |row|
            row.blood_type ? row.blood_type : "Sconosciuto"
          end,
          tag_list do |row|
            row.tag_list ? row.tag_list : "Sconosciuto"
          end,


      # invitation_ids,

      # "#{user.invitation_ids.join(';')}",


      # user.hobbies.pluck(:title).join(', ')
      ].uniq
      user_csv << ["Campaign Information for: #{first_name} #{last_name}"]
      user_csv << ["Questionnaire ID", "Campaign"]
      invitations.each do |invitation|
        user_csv << [
            "#{invitation.questionnaire_id}",
            "#{invitation.campaign}"
        ].uniq
      end
      user_csv << ["Questionnaire Information for: #{first_name} #{last_name}"]
      user_csv << ["Questionnaire ID", "Questionnaire title", "Description", "Completed?", "IDs"]

      questionnaires.each do |invitation|
        user_csv << [
            "#{invitation.id}",
            "#{invitation.title}",
            "#{invitation.desc}",
            "#{invitation.completed}",


        ].uniq

      end

      user_csv << ["Questionnaire questions for: #{first_name} #{last_name}"]
      user_csv << ["Questionnaire ID", "Questionnaire Type", "Questions", "Options IDs", "Options", "Completed?"]
      questionnaire_questions.each do |invitation|
        user_csv << [
            "#{invitation.questionnaire_id}",
            " #{invitation.q_type}",
            " #{invitation.text}",
            " #{invitation.option_ids.join(';')}",


        # user_csv << ["#{first_name}s Answer"]


        # invitation.options.each do |option|
        # user_csv << [
        #     "#{option.text.join(';')}"
        # ].uniq
        # end
        # " #{invitation.options.join{';'}}"

        ].uniq
        user_csv << ["Options & Score"]
        invitation.options.each_with_index do |qq, index|
          user_csv << ["Option #{index}" => qq.text, "Score" => qq.score]
        end


      end

      user_csv << ["Questionnaire options for: #{first_name} #{last_name}"]
      user_csv << ["Question ID", "Option", "Score"]
      options.each do |invitation|
        user_csv << [
            "#{invitation.questionnaire_question_id}",
            "#{invitation.text}",
            "#{invitation.score}",


        ].uniq

      end
      user_csv << [" Options for: #{first_name} #{last_name}s Answers"]
      user_csv << ["#{first_name}s answers"]
      questionnaire_answers.each_with_index do |invitation, index|

        user_csv << ["Campaign" => invitation.invitation_id, "Answer #{index}" => invitation.text]
        # questionnaire_answers.each.questionnaire_question.options.score

      end
    end
  end


  #   def self.to_csv
  #     attributes = %w{id first_name last_name email cellphone state fitbit_status age py_cluster patient_objective
  # gender height weight blood_type tag_list}
  #
  #     CSV.generate(headers: true) do |csv|
  #       csv << attributes
  #       all.each do |user|
  #         csv << attributes.map{ |attr| user.send(attr) || "null" }.uniq
  #       end
  #     end
  #   end
  #


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

	def active_objective
		objectives.to_a.find { |objective|
			objective.start_date <= Date.today && Date.today <= objective.end_date
		}
	end

	def scheduled_objectives
		objectives.to_a.select { |objective|
			objective.start_date > Date.today
		}
	end

	def terminated_objectives
		objectives.select { |objective|
			objective.end_date < Date.today
		}
	end


  include AASM # Act As State Machine

  # default column: aasm_state
  # no direct assignment to aasm_state
  # return false instead of exceptions
  aasm :whiny_transitions => false do

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
                  :after => Proc.new {|*args| register_patient_response(*args)}
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
    actuator.send_reply_with_keyboard("Non hai più feedback da dare per oggi! Prosegui con le attività 🚀.", GeneralActions.menu_keyboard)
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
