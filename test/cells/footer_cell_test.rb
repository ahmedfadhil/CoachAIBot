require 'test_helper'

class FooterCellTest < Cell::TestCase
  test "show" do
    html = cell("footer").(:show)
    assert html.match /<p>/
  end


end
