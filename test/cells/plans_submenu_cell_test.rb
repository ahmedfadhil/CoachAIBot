require 'test_helper'

class PlansSubmenuCellTest < Cell::TestCase
  test "show" do
    html = cell("plans_submenu").(:show)
    assert html.match /<p>/
  end


end
