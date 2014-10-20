class WalletController < ApplicationController
  
  before_action :set_user_from_session, only:  [:cashin, :charge]
  
  def cashin
    w = Wallet.get_wallet($user);
      wr = WalletRequest.create_cash_in_wallet_request(w.id)
        respond_to do |format|
      format.json { render :json => wr.as_json, status: :ok }
    end
  end
  
  
  def charge

    log = Logger.new(STDOUT)
    log.level = Logger::INFO
    prms= params.require(:chargeMoney)
    reciever_user_token= prms[:accountid]
    amount = prms[:amount]
    currency = prms[:currency]
    message = prms[:message]
    privacy = prms[:global]

    begin
      reciever = Profile.where(:user_token => reciever_user_token).first!
    rescue
      @like={:result=>404}
      respond_to do |format|
        format.json { render :json => @like.as_json, status: :not_found }
      end
    return
    end

    @like=Object.new

    begin
      charge_request = ChargeRequest.new
      charge_request.feed_date = Time.now
      charge_request.status = 0
      charge_request.fType = 3
      charge_request.amount = amount #сколько бабала просим перевести
      charge_request.currency = currency
      charge_request.privacy = privacy
      charge_request.message = message

      charge_request.from_profile=@user
      charge_request.to_profile=reciever

      charge_request.save!
    rescue
      @like={:result=>0}
      respond_to do |format|
        format.json { render :json => @like.as_json, status: :ok }
      end
    return
    end
    @like={:result=>0}
    respond_to do |format|
      format.json { render :json => @like.as_json, status: :ok }
    end
  end

end
