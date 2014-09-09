module FriendsHelper


  #1- фигачить протокол прямо в эти методы
  #2- сделать соапуай тесты
  :public
  def self.invite_new_friend(user, friend_email)
    if user.email ===friend_email
      return false
    end
    #валидация емэйл
    invite_email = AccountValidators::get_email_match(friend_email)
    unless invite_email
      return false #емэйл имеет некорректный формат
    end
    #  поиск существующего аккаунта
    temp_profile = friends_search(friend_email)
    #  если аккаунт не найден, то создать новый/временный
    unless temp_profile
      temp_profile = Profile.new;
      temp_profile.temp_account=TRUE
      temp_profile.user_token = friend_email
      temp_profile.email = friend_email
      temp_profile.confirm_type=0
      unless temp_profile.save
        @result = Object
        @result = {:result => 4,:message => "not registered"}
        respond_to do |format|
          format.json { render :json => @result.as_json, status: :error }
        end
        return false;
      end
    end
    #  так, аккаунт еже сеть в любом случае. делаем ему предложение дружбы.
    create_friendship_request(user, temp_profile)
    #
    unless temp_profile.temp_account #если временный аккаунт, то без посыла EMAIL
      Emailer.email_friend_invite(friend_email,user )
    end
  end

  def self.mark_feed_as_viewed(user, feed_id)
    feed=user.destinationFeeds.where(:id=>feed_id).first
    unless feed
      return false
    end
    return feed.update(:viewed=>1)
  end

  def self.create_friendship_request(user, friend)
    unless user
      return
    end
    unless friend
      return
    end

    if FriendshipRequest.where( :from_profile_id => user.id, :to_profile_id => friend.id).any?
      return #не давать создавать повторный запрос
    end

    request= FriendshipRequest.new
    request.from_profile=user
    request.to_profile=friend
    request.fType = 20
    request.feed_date = Time.now
    request.privacy = 2 #friends
    request.message = 'be my friend'
    return request.save
  end

  def self.get_friendship_requests(user)
    unless user
      return
    end
    return FriendshipRequest.find_by_to_profile_id(user.id)
  end

  def self.get_friendship_requests_count(user)
    unless user
      return
    end
    return FriendshipRequest.where(:to_profile_id => user.id).count
  end

  #method /profile/new
  def self.get_new_feeds_count(user)
    unless user
      return
    end
    return Feed.where(:to_profile_id => user.id,:viewed => 0).count
  end

  def self.friendship_request_status(user, friend_id, status_new)
    friend= Profile.find_by_user_token(friend_id)
    unless friend
      ret false
    end
    #найти запрос от друга
    friendship_request = find_request(user, friend.user_token, 0)
    if(friendship_request)
      ActiveRecord::Base.transaction do
        friendship_request.update(:status=>status_new)
        create_friendship(user,friend)
      end
    end
  end

  def self.friendship_request_cancel(user_who_made_request, friend_account_id)
    #найти запрос от друга
    #найти запрос от друга
    friendship_request = find_request(user, friend_account_id, 0)
    if(friendship_request)
      friendship_request.update(:status=>4)
    end
  end

  def self.get_friends(user)
    #прежде чем выдавать список друзей, нужно их получить

    friend_api_format = Array.new
    user.lovers.each    { |user|
      friend_api_format <<
          {
              :accountid=>user.user_token,
              :pic =>  user.pic_url,
              :name=> user.name,
              :surname=> user.surname
          }
    }

    return friend_api_format
  end

  def self.friends_count(user)
    return  user.lovers.count #todo использовать поле friends_count профиля
  end

  def self.friends_search(email_search)
    profile_result= Profile.where(:email => email_search).first
    if profile_result
      return profile_result
    end
    return nil
  end

:private

  def self.find_request(user, friend_account_id, request_status)
    friend_id = Profile.find_by_user_token(friend_account_id)

    return FriendshipRequest.where(:from_profile_id => user.id, :to_profile_id =>friend_id.id, :status => request_status ).first
  end

  def  self.is_friendship_exist(user_1,user_2)
    Friend.where(friend_id: user_1, profile_id: user_2).any?
  end

  def self.create_friendship(user, friend)
    #start transaction
    #ActiveRecord::Base.transaction do
      #check if friendship is not exist
      unless is_friendship_exist(friend.id, user.id)
        user.lovers << friend
        user.save!
      end
      unless is_friendship_exist(user.id, friend.id)
        friend.lovers << user
        friend.save!
      end
   # end
    #commit transaction
  end

end
