require 'test_helper'

class MoodControllerTest < ActionController::TestCase
  test "should get set_mood" do
    get :set_mood
    assert_response :success
  end

end
