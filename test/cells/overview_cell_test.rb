require 'test_helper'

class OverviewCellTest < Cell::TestCase
  test "show" do
    html = cell("overview").(:show)
    assert html.match /<p>/
  end


end
