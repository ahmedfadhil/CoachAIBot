require 'test_helper'

class PatientControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get patient_all_url
    assert_response :success
  end

end
