require 'test_helper'

class FeaturesCellTest < Cell::TestCase
  test "show" do
    html = cell("features").(:show)
    assert html.match /<p>/
  end


end
