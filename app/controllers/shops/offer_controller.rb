class Shops::OfferController < ApplicationController

  before_action :set_user_from_session, only:  [:new_offer]

  def new_offer

      offer_params = params.require(:offer).permit(:shop, :text, :price, :old_price, :currency)

      if ($user != nil) && ($user.wallet_type == Profile::ACCOUNT_TYPE[:biz])
        offer = Offer.create_offer(offer_params[:shop], $user.id, offer_params[:text], offer_params[:price], offer_params[:old_price], offer_params[:currency])
        result = {:result => 0, :shop => offer.as_json, :message => 'ok'}
        respond_to do |format|
          format.json { render :json => result.as_json, status: :ok }
        end
      else
        result = {:result => -1, :message => 'forbidden'}
        respond_to do |format|
          format.json { render :json => result.as_json, status: :forbidden }
        end
      end

  end
end
