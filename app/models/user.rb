class User < ApplicationRecord

  has_and_belongs_to_many :plans

  validates_uniqueness_of :telegram_id
  validates :first_name, presence: true
  validates :last_name, presence: true

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
