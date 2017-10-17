require 'test_helper'

class HomeHeaderCellTest < Cell::TestCase
  test "show" do
    html = cell("home_header").(:show)
    assert html.match /<p>/
  end


end
