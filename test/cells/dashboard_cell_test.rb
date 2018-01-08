require 'test_helper'

class DashboardCellTest < Cell::TestCase
  test "show" do
    html = cell("dashboard").(:show)
    assert html.match /<p>/
  end


end
