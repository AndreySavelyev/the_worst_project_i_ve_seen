require 'test_helper'

class ProfilesControllerTest < ActionController::TestCase
  setup do
    @profile = profiles(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:profiles)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create profile" do
    assert_difference('Profile.count') do
      post :create, profile: { birthday: @profile.birthday, company_name: @profile.company_name, created_at: @profile.created_at, email: @profile.email, fb_token: @profile.fb_token, iban: @profile.iban, name: @profile.name, password: @profile.password, phone: @profile.phone, pic_url: @profile.pic_url, reg_num: @profile.reg_num, salt: @profile.salt, surname: @profile.surname, updated_at: @profile.updated_at, user_token: @profile.user_token }
    end

    assert_redirected_to profile_path(assigns(:profile))
  end

  test "should show profile" do
    get :show, id: @profile
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @profile
    assert_response :success
  end

  test "should update profile" do
    patch :update, id: @profile, profile: { birthday: @profile.birthday, company_name: @profile.company_name, created_at: @profile.created_at, email: @profile.email, fb_token: @profile.fb_token, iban: @profile.iban, name: @profile.name, password: @profile.password, phone: @profile.phone, pic_url: @profile.pic_url, reg_num: @profile.reg_num, salt: @profile.salt, surname: @profile.surname, updated_at: @profile.updated_at, user_token: @profile.user_token }
    assert_redirected_to profile_path(assigns(:profile))
  end

  test "should destroy profile" do
    assert_difference('Profile.count', -1) do
      delete :destroy, id: @profile
    end

    assert_redirected_to profiles_path
  end
end
