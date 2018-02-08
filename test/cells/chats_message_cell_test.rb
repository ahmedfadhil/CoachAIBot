require 'test_helper'

class ChatsMessageCellTest < Cell::TestCase
  test "show" do
    html = cell("chats_message").(:show)
    assert html.match /<p>/
  end


end
