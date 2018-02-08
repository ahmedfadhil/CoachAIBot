require 'test_helper'

class ChatCellTest < Cell::TestCase
  test "show" do
    html = cell("chat").(:show)
    assert html.match /<p>/
  end


end
