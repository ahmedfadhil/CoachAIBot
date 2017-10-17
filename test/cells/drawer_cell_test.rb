require 'test_helper'

class DrawerCellTest < Cell::TestCase
  test "show" do
    html = cell("drawer").(:show)
    assert html.match /<p>/
  end


end
