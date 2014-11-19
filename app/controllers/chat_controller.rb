class ChatController < ApplicationController

  before_action :set_user_from_session, only: [:send]

  def send(args)

   p = params.require(:tissue).permit(:to_account_id, :text)
   to_profile = Profile::get_by_accountid(p[:to_account_id])

   ChatTissue::send_tissue($user.id, to_profile.id, p[:text])

   result = {:result => 0, :message => 'message sent', :code => 200}
   respond_to do |format|
     format.json { render :json => result.as_json, status: result[:code] }
   end
  end

end
