require 'test_helper'

class HeadTagCellTest < Cell::TestCase
  test "show" do
    html = cell("head_tag").(:show)
    assert html.match /<p>/
  end


end
