require 'test_helper'

class Shops::OfferControllerTest < ActionController::TestCase
  test "should get new_offer" do
    get :new_offer
    assert_response :success
  end

end
