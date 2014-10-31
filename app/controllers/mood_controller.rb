class MoodController < ApplicationController

  before_action :set_user_from_session, only:  [:set_mood]

  def set_mood

   index_p = params.require(:mood).permit(:index)

   index = index_p[:index].to_s.to_i

   if index >= 0 && index <= 6
     Mood.mood($user.id, index)
     $user.mood = index
     $user.save
   else
     raise ArgumentError, 'Mood index is not valid'
   end

   respond_to do |format|
     format.json { render :json => ProfilesHelper::get_profile_format($user), status: :ok }
    end

  end

end
