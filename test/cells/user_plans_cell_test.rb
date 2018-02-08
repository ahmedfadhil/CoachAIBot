require 'test_helper'

class UserPlansCellTest < Cell::TestCase
  test "show" do
    html = cell("user_plans").(:show)
    assert html.match /<p>/
  end


end
