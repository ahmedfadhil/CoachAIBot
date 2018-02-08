require 'test_helper'

class MessagesCellTest < Cell::TestCase
  test "show" do
    html = cell("messages").(:show)
    assert html.match /<p>/
  end


end
