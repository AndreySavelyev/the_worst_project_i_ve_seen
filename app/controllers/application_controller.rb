class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #protect_from_forgery with: :exception
  
  $user = nil;
  
  def set_user_from_session_and_check_registration
    set_user_from_session
    if(@user)
      check_user_token_valid(@user);
    end
  end

  def set_user_from_session
    session_token = request.headers['session-token'];
    #collecting some data for user
    session = Session.find_by_SessionId(session_token);
    unless(checkSessionValid(session))
      result = {:result => 11,:message =>"session not valid", :expiration => session ? session.TimeToDie.to_s(:session_date_time) : "", :session => session ? session.SessionId : "" }
      respond_to do |format|
        format.json { render :json => result.as_json, status: :unauthorized }
      end
    return;
    end
    $user = session.profile;
  end
  
 def checkSessionValid(session)
   
    unless(session)
    return false;
    end

    if(session.TimeToDie<Time.now)
    return false;
    end
    return true;
  end
  
end
