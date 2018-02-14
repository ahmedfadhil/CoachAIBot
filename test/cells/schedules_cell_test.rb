require 'test_helper'

class SchedulesCellTest < Cell::TestCase
  test "show" do
    html = cell("schedules").(:show)
    assert html.match /<p>/
  end


end
