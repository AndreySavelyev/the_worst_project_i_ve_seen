class PushNotificationsController < ApplicationController

  before_action :set_user_from_session, only:  [:token]

  def token
    token = params.require(:token)
    platform = params[:platform] || 'ios'

    respond_to do |format|
      format.json { render :json => PushTokens::get_by_token(token, platform, $user.id).as_json, status: :ok }
    end

  end
end
