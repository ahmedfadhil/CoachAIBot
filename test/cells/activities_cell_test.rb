require 'test_helper'

class ActivitiesCellTest < Cell::TestCase
  test "show" do
    html = cell("activities").(:show)
    assert html.match /<p>/
  end


end
