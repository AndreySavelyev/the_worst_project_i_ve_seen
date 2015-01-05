class Shops::OfferController < ApplicationController

  include GlobalConstants

  before_action :set_user_from_session, only:  [:new_offer, :list, :change]

  def new_offer

      offer_params = params.require(:offer).permit(:shop, :text, :price, :old_price, :currency, :url)

      if ($user != nil) && ($user.wallet_type == GlobalConstants::ACCOUNT_TYPE[:biz])
        offer = Shops::Offer.create_offer(offer_params[:shop], $user.id, offer_params[:text], offer_params[:price], offer_params[:old_price], offer_params[:currency], offer_params[:url])
        result = {:result => 0, :offer => offer.as_json, :message => 'ok'}
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

  def list
    offers = Array.new

    Shops::Offer.get_all(params[:published]) do |offer|
      offers << {
          :id=> offer.id,
          :text=> offer.text,
          :currency=> IsoCurrency.find(offer.currency).Alpha3Code,
          :price=> offer.price,
          :shopname=> offer.shop.name,
          :shoppic=> offer.shop.avatar_url,
          :pic=> offer.avatar_url,
          :url=> offer.url
      } end

    result = {:result => 0, :offers => offers.as_json, :message => 'ok'}

    respond_to do |format|
      format.json { render :json => result.as_json, status: :ok }
    end
  end

  def change
    offer_params = params.require(:offer).permit(:id, :text, :price, :old_price, :currency, :url, :published)
    if ($user != nil) && ($user.wallet_type == GlobalConstants::ACCOUNT_TYPE[:biz])
      offer = Shops::Offer.update_offer(offer_params[:id], $user.id, offer_params[:published], offer_params[:text], offer_params[:price], offer_params[:old_price], offer_params[:currency], offer_params[:url])
      result = {:result => 0, :offer => offer.as_json, :message => 'ok'}
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
