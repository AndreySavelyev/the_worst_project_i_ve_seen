class AvatarController < ApplicationController

  before_action :set_user_from_session, only:  [:upload, :upload_offer, :upload_shop ]

  def upload

    $user.image_data = params[:image_data]
    $user.decode_image_data

    result = {:url =>  $user.avatar}

    respond_to do |format|
      format.json { render :json => result.as_json, status: :ok }
    end
  end

  def upload_offer

    upload_params = params.permit(:id, :image_data)

    offer = Shops::Offer.get(upload_params[:id], $user.id)
    offer.image_data = upload_params[:image_data]
    offer.decode_image_data

    result = {:url =>  offer.avatar}

    respond_to do |format|
      format.json { render :json => result.as_json, status: :ok }
    end

  end

  def upload_shop

    upload_params = params.permit(:id, :image_data)

    shop = Shops::Shop.get(upload_params[:id], $user.id)
    shop.image_data = upload_params[:image_data]
    shop.decode_image_data

    result = {:url =>  shop.avatar}

    respond_to do |format|
      format.json { render :json => result.as_json, status: :ok }
    end

  end

end
