class WalletController < ApplicationController
  
  before_action :set_user_from_session, only:  [:cashin]
  
  def cashin
    w = Wallet::get_wallet($user)
      wr = WalletRequest.create_cash_in_wallet_request(w.id)
    respond_to do |format|
      format.json { render :json => wr.as_json, status: :ok }
    end
  end
  
end
