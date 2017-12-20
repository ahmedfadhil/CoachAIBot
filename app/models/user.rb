require "#{Rails.root}/lib/bot_v2/messenger"
require "#{Rails.root}/lib/bot_v2/activity_informer"
require "#{Rails.root}/lib/bot_v2/feedback_manager"

class User < ApplicationRecord
  has_many :communications, dependent: :destroy
  has_many :chats, dependent: :destroy
	has_many :daily_logs, dependent: :destroy
  has_many :plans, dependent: :destroy
  has_one :feature, dependent: :destroy
  belongs_to :coach_user, optional: true

  validates :telegram_id, uniqueness: true, allow_nil: true
  validates_uniqueness_of :email, message: 'Email in uso. Scegli altra email.'
  validates_uniqueness_of :cellphone, message: 'Cellulare in uso. Scegli un altro numero di cellulare.'
  validates :first_name, presence: { message: 'Inserisci nome.' }, length: { maximum: 50 }
  validates :last_name, presence: { message: 'Inserisci cognome.' }, length: { maximum: 50 }
  validates :cellphone, presence: { message: 'Inserisci numero cellulare.' }, length: { maximum: 25, message: 'Numero Cellulare troppo lungo. Max 25.' }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: { message: "Email non puo' essere vuota." }, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX, message: "Formato dell'email non valido. Usare email della forma esempio@myemail.org" }

  def set_bot_command_data(state)
    self.bot_command_data = state.to_json
    save
  end

  def get_bot_command_data
    self.bot_command_data
  end

  def reset_user_state
    hash = { :state => 'no_state'}
    self.bot_command_data = hash.to_json
    save
  end

  def profiled?
    features = self.feature
    features.nil? ? false : ((features.health == 1) && (features.physical == 1) && (features.coping == 1) && (features.mental == 1))
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
    state :idle, :initial => true
    state :messages, :activities, :feedbacks, :feedbacking, :experiment

    event :feedback do
      transitions :from => :feedbacking, :to => :feedbacks, :after => Proc.new {|*args| register_answer(*args)}, :guard => Proc.new {|*args| is_answer?(*args) }
      transitions :from => :feedbacking, :to => :feedbacking, :after => :wrong_answer
    end

    event :start_feedbacking do
      transitions :from => :feedbacks, :to => :feedbacking, :after => Proc.new {|*args| ask_oldest_feedback(*args)}, :guard => Proc.new {|*args| needs_feedback?(*args) }
      transitions :from => :feedbacks, :to => :feedbacks, :after => Proc.new {|*args| maybe_wrong(*args) }
    end

    event :show_undone_feedbacks do
      transitions :from => :idle, :to => :feedbacks, :after => :send_undone_feedbacks, :guard => :undone_feedbacks?
      transitions :from => :idle, :to => :idle, :after => :inform_no_feedbacks
    end

    event :get_activities do
      transitions :from => :idle, :to => :activities, :after => :send_activities, :guard => :activities_present?
      transitions :from => :idle, :to => :idle, :after => :inform_no_activities
    end

    event :cancel do
      transitions :from => :activities, :to => :idle, :after => :send_menu_from_activities
      transitions :from => :feedbacks, :to => :idle, :after => :send_menu_from_feedbacks
      transitions :from => :feedbacking, :to => :idle, :after => :send_menu_from_feedbacking
      transitions :from => :messages, :to => :idle, :after => :send_menu_from_messages
    end

    event :get_details do
      transitions :from => :activities, :to => :idle, :after => :send_activities_details
      transitions :from => :feedbacks, :to => :feedbacks, :after => :send_feedbacks_details
    end

    event :get_messages do
      transitions :from => :idle, :to => :messages, :after => :send_messages, :guard => :messages_present?
      transitions :from => :idle, :to => :idle, :after => :inform_no_messages
    end

    event :respond do
      transitions :from => :messages, :to => :idle, :after => Proc.new {|*args| register_patient_response(*args) }
    end

  end

  private

  # manages <feedbacks and feedbacking> states

  def wrong_answer(text)
    FeedbackManager.new(self, JSON.parse(self.get_bot_command_data)).wrong_answer
  end

  def is_answer?(text)
    FeedbackManager.new(self, JSON.parse(self.get_bot_command_data)).is_answer(text)
  end

  def needs_feedback?(plan_name)
    FeedbackManager.new(self, JSON.parse(self.get_bot_command_data)).needs_feedback?(plan_name)
  end

  def send_menu_from_feedbacking
    # ToDo -> Change
    send_menu_from_feedbacks
  end

  def maybe_wrong(text) # we ignore the input because the guard has to have an input parameter
    FeedbackManager.new(self, JSON.parse(self.get_bot_command_data))
        .please_choose_plan(GeneralActions.plans_names(GeneralActions.new(self, JSON.parse(self.get_bot_command_data)).plans_needing_feedback))
  end

  def register_answer(answer)
    FeedbackManager.new(self, JSON.parse(self.get_bot_command_data)).register_answer(answer)
  end

  def plan_needs_feedback?
    plan_name = JSON.parse(self.get_bot_command_data)['plan_name']
    FeedbackManager.new(self, JSON.parse(self.get_bot_command_data)).needs_feedback?(plan_name)
  end

  def ask_oldest_feedback(plan_name)
    FeedbackManager.new(self, JSON.parse(self.get_bot_command_data)).ask_oldest_feedback(plan_name)
  end

  def send_feedbacks_details
    FeedbackManager.new(self, JSON.parse(self.get_bot_command_data)).send_details
  end

  def send_menu_from_feedbacks
    FeedbackManager.new(self, JSON.parse(self.get_bot_command_data)).send_menu
  end

  def inform_no_feedbacks
    FeedbackManager.new(self, JSON.parse(self.get_bot_command_data)).inform_no_feedbacks
  end

  def send_undone_feedbacks
    FeedbackManager.new(self, JSON.parse(self.get_bot_command_data)).send_undone_feedbacks
  end

  def undone_feedbacks?
    FeedbackManager.new(self, JSON.parse(self.get_bot_command_data)).undone_feedbacks?
  end

  # manages <activities> state

  def send_activities_details
    ActivityInformer.new(self, JSON.parse(self.get_bot_command_data)).send_details
  end

  def send_activities
    ActivityInformer.new(self, JSON.parse(self.get_bot_command_data)).send_activities
  end

  def inform_no_activities
    ActivityInformer.new(self, JSON.parse(self.get_bot_command_data)).inform_no_activities
  end

  def send_menu_from_activities
    ActivityInformer.new(self, JSON.parse(self.get_bot_command_data)).send_menu
  end

  def activities_present?
    ActivityInformer.new(self, JSON.parse(self.get_bot_command_data)).activities_present?
  end

  # manages <messages> state

  def send_messages
    Messenger.new(self, JSON.parse(self.get_bot_command_data)).inform
  end

  def messages_present?
    Messenger.new(self, JSON.parse(self.get_bot_command_data)).messages_present?
  end

  def inform_no_messages
    Messenger.new(self, JSON.parse(self.get_bot_command_data)).inform_no_messages
  end

  def send_menu_from_messages
    Messenger.new(self, JSON.parse(self.get_bot_command_data)).send_menu
  end

  def register_patient_response(response)
    Messenger.new(self, JSON.parse(self.get_bot_command_data)).register_patient_response(response)
  end

  # will be called if any event fails
  def aasm_event_failed(event_name, old_state_name)
    # use custom exception/messages, report metrics, etc
  end

end
