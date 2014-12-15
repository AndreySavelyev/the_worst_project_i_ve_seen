class Shops::ShopController < ApplicationController

  before_action :set_user_from_session, only:  [:new_shop]

  def new_shop

    shop_params = params.require(:shop).permit(:name, :text)

    if ($user != nil) && ($user.wallet_type == Profile::ACCOUNT_TYPE[:biz] || $user.wallet_type == Profile::ACCOUNT_TYPE[:partner])
      shop = Shops::Shop.create_shop($user, shop_params[:name], shop_params[:text])
      result = {:result => 0, :shop => shop.as_json, :message => 'ok'}
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
