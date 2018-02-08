require 'test_helper'

class UserMenuCellTest < Cell::TestCase
  test "show" do
    html = cell("user_menu").(:show)
    assert html.match /<p>/
  end


end
