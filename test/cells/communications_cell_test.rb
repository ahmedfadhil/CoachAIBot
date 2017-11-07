require 'test_helper'

class CommunicationsCellTest < Cell::TestCase
  test "show" do
    html = cell("communications").(:show)
    assert html.match /<p>/
  end


end
