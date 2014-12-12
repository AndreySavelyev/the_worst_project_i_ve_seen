require 'test_helper'

class Shops::ShopControllerTest < ActionController::TestCase
  test "should get new_shop" do
    get :new_shop
    assert_response :success
  end

end
