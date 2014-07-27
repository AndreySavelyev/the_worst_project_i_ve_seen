class AccountValidators

  def AccountValidators.check_user_token_valid(user)
    unless(user)
      @newUser=Profile.new;
      @newUser <<
          {
              :result => 6,
              :message => "app token not valid"
          }
      respond_to do |format|
        format.json { render :signup_error, status: :unauthorized, location: profiles_url }
      end
      return;
    end
  end

  def  AccountValidators.check_app_token_valid(app)
    unless(app)
      @newUser=Profile.new;
      @newUser =
          {
              :result => 7,
              :message => "app token not valid"
          }
      respond_to do |format|
        format.json { render :signup_error, status: :unauthorized, location: profiles_url }
      end
      return;
    end
  end
end