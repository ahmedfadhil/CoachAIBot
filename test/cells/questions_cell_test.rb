require 'test_helper'

class QuestionsCellTest < Cell::TestCase
  test "show" do
    html = cell("questions").(:show)
    assert html.match /<p>/
  end


end
