require 'test_helper'

class CommunicationCellTest < Cell::TestCase
  test "show" do
    html = cell("communication").(:show)
    assert html.match /<p>/
  end


end
