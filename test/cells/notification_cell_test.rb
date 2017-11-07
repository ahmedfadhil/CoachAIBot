require 'test_helper'

class NotificationCellTest < Cell::TestCase
  test "show" do
    html = cell("notification").(:show)
    assert html.match /<p>/
  end


end
