require 'test_helper'

class ProfileNavCellTest < Cell::TestCase
  test "show" do
    html = cell("profile_nav").(:show)
    assert html.match /<p>/
  end


end
