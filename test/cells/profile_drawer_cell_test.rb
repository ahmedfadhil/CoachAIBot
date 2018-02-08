require 'test_helper'

class ProfileDrawerCellTest < Cell::TestCase
  test "show" do
    html = cell("profile_drawer").(:show)
    assert html.match /<p>/
  end


end
