require 'test_helper'

class PushNotificationsControllerTest < ActionController::TestCase
  test "should get save_token" do
    get :save_token
    assert_response :success
  end

end
