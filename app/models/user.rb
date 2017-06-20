class User < ApplicationRecord

  validates_uniqueness_of :telegram_id

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
