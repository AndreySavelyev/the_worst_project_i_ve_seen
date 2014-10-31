class AvatarController < ApplicationController

  before_action :set_user_from_session, only:  [:upload, :get ]

  def upload
    puts "starts"
    $user.image_data = params[:image_data]
    $user.decode_image_data

    respond_to do |format|
      format.json { render :json => $user.avatar.as_json, status: :ok }
    end
  end

  def get

  end
end
