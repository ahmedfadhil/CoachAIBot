require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(telegram_id: 'telegram_id', first_name: 'first_name', last_name: 'last_name', email: 'user@example.com', bot_command_data:'{ :state => "no_state"}')
  end

  test 'should be valid' do
    assert @user.valid?
  end
end
