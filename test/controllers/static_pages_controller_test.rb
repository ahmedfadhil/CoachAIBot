require 'test_helper'

class StaticPagesControllerTest < ActionDispatch::IntegrationTest

  test "should get help" do
    get static_pages_help_url
    assert_response :success
    assert_select "title", "Help | CoachAI"
  end

  test "should get about" do
    get static_pages_about_url
    assert_response :success
    assert_select "title", "About | CoachAI"
  end

end
