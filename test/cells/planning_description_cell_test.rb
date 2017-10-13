require 'test_helper'

class PlanningDescriptionCellTest < Cell::TestCase
  test "show" do
    html = cell("planning_description").(:show)
    assert html.match /<p>/
  end


end
