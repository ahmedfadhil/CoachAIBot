class User < ApplicationRecord
	has_many :objectives
	has_many :daily_logs
  has_many :plans, dependent: :destroy
  has_one :feature, dependent: :destroy
  belongs_to :coach_user, optional: true

  attr_accessor :physical_score,:diet_score,:mental_score

  validates :telegram_id, uniqueness: true, allow_nil: true
  validates_uniqueness_of :email, message: 'Email in uso. Scegli altra email.'
  validates_uniqueness_of :cellphone, message: 'Cellulare in uso. Scegli un altro numero di cellulare.'
  validates :first_name, presence: { message: 'Inserisci nome.' }, length: { maximum: 50 }
  validates :last_name, presence: { message: 'Inserisci cognome.' }, length: { maximum: 50 }
  validates :cellphone, presence: { message: 'Inserisci numero cellulare.' }, length: { maximum: 25, message: 'Numero Cellulare troppo lungo. Max 25.' }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: { message: "Email non puo' essere vuota." }, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX, message: "Formato dell'email non valido. Usare email della forma esempio@myemail.org" }

	serialize :properties, JSON
	serialize :access_token, JSON
	enum fitbit_status: {fitbit_disabled: 0, fitbit_invited: 1, fitbit_enabled: 2}

  def set_user_state(state)
    self.bot_command_data = state.to_json
    save
  end

  def get_user_state
    self.bot_command_data
  end

  def reset_user_state
    hash = { :state => "no_state"}
    self.bot_command_data = hash.to_json
    save
  end
end
