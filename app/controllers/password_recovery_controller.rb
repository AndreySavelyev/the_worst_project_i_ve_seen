class PasswordRecoveryController < ApplicationController

  rescue_from ActiveRecord::RecordNotFound, with: :not_found_error

  def recover

    email = params.require(:recovery).permit(:email)

    profile = Profile::get_by_email(email[:email])
    w = profile.get_wallet

    r = WalletRequest::create_password_recovery_request(w.id)

    Emailer.email_recovery(r, Settings.wallet_url + '/recovery/changepass').deliver

    @result = {:result => 0,:message => 'recovery email was sent'}

    respond_to do |format|
      format.json { render :json => @result.as_json, status: :ok }
    end

  end

  def token
    token = params.permit(:token)

    request = WalletRequest::find_by_token(token[:token])
    @result = {:result => request.token, :message => 'token is ok'}

    respond_to do |format|
      format.json { render :json => @result.as_json, status: :ok }
    end
  end


  def password
    password = params.require(:password).permit(:pass_phrase, :token)
    request = WalletRequest::find_by_token(password[:token])
    profile = request.sourceWallet.profile
    profile.set_password(password[:pass_phrase])

    Emailer.email_recovery_success(request).deliver
    WalletRequest.delete_request(request.id)

    @result = {:result => request.token, :message => 'password was changed'}

    respond_to do |format|
      format.json { render :json => @result.as_json, status: :ok }
    end

  end

  def not_found_error
    @result = {:result =>-1, :message => 'token was not found'}
    respond_to do |format|
      format.json { render :json => @result.as_json, status: :not_found }
    end
  end

end
