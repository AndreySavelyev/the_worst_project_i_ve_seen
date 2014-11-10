require 'test_helper'

class PasswordRecoveryControllerTest < ActionController::TestCase
  test "should get request" do
    get :request
    assert_response :success
  end

end
