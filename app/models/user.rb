class User < ApplicationRecord
  has_and_belongs_to_many :plan
  has_many :q_schedule

  validates :telegram_id, uniqueness: true, allow_nil: true
  validates_uniqueness_of :email
  validates_uniqueness_of :cellphone
  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, presence: true, length: { maximum: 50 }
  validates :cellphone, presence: true, length: { maximum: 25 }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }

  def set_user_state(state)
    self.bot_command_data = state.to_json
    save
  end

  def get_user_state
    return self.bot_command_data
  end

  def reset_user_state
    hash = { :state => "no_state"}
    self.bot_command_data = hash.to_json
    save
  end
end
