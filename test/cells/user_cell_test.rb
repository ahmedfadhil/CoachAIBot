require 'test_helper'

class UserCellTest < Cell::TestCase
  test "show" do
    html = cell("user").(:show)
    assert html.match /<p>/
  end


end
