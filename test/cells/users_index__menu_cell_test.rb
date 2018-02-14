require 'test_helper'

class UsersIndexMenuCellTest < Cell::TestCase
  test "show" do
    html = cell("users_index__menu").(:show)
    assert html.match /<p>/
  end


end
