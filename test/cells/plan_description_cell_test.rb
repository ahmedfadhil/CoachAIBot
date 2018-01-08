require 'test_helper'

class PlanDescriptionCellTest < Cell::TestCase
  test "show" do
    html = cell("plan_description").(:show)
    assert html.match /<p>/
  end


end
