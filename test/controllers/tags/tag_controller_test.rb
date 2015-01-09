require 'test_helper'

class Tags::TagControllerTest < ActionController::TestCase
  test "should get tag_service" do
    get :tag_service
    assert_response :success
  end

end
