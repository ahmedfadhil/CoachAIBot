require 'test_helper'

class LayoutCellTest < Cell::TestCase
  test "show" do
    html = cell("layout").(:show)
    assert html.match /<p>/
  end


end
