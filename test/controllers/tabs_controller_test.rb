require 'test_helper'

class TabsControllerTest < ActionController::TestCase
  test "should get get_tabs" do
    get :get_tabs
    assert_response :success
  end

end
