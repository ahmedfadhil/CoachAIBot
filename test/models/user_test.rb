require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(telegram_id: 'telegram_id', first_name: 'First_Name', last_name: 'Last_Name', bot_command_data:'{}', email: 'example@io.io', cellphone: '00000')
  end

  test 'should be valid' do
    assert @user.valid?
  end

  test 'first_name should be present' do
    @user.first_name = ''
    assert_not @user.valid?
  end

  test 'last_name should be present' do
    @user.last_name = ''
    assert_not @user.valid?
  end

  test 'cellphone should be present' do
    @user.cellphone = ''
    assert_not @user.valid?
  end

  test 'email should be present' do
    @user.email = ''
    assert_not @user.valid?
  end

  test 'first_name should not be too long' do
    @user.first_name = 'a' * 51
    assert_not @user.valid?
  end

  test 'last_name should not be too long' do
    @user.last_name = 'a' * 51
    assert_not @user.valid?
  end

  test 'cellphone should not be too long' do
    @user.cellphone = 'a' * 51
    assert_not @user.valid?
  end

  test 'email should not be too long' do
    @user.email = 'a' * 244 + '@example.com'
    assert_not @user.valid?
  end

  test 'email validation should accept valid addresses' do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@bazio.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                         foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end


end
