class ChatController < ApplicationController

  before_action :set_user_from_session, only: [:send_tissue, :get_tissues]

  def send_tissue

   p = params.require(:tissue).permit(:to_account_id, :text)
   to_profile = Profile::get_by_accountid(p[:to_account_id])

   tissue = ChatTissue::send_tissue($user.id, to_profile.id, p[:text])

   PushTokens::send_tissue_push(tissue)

   respond_to do |format|
     format.json { render :json => tissue.as_json, status: :ok }
   end

  end

  def get_tissues

    p = params.permit(:to_account_id)

    to_profile = Profile::get_by_accountid(p[:to_account_id])
    list = ChatTissue::get_tissues($user.id, to_profile.id)
    list.reverse!

    list = ChatHelper::get_tissue_message_format(list)

    respond_to do |format|
      format.json { render :json => list.as_json, status: 200 }
    end

  end

end
