class FeedsController < ApplicationController

  #helper FeedsHelper;

  before_action :set_user_from_session, only:  [:feed]
  
  def feed

    query_privacy = params.require(:global)
    
    feeds = nil

    case query_privacy
    when 0
      feeds = get_global_feed
    when 1
      feeds = get_friends_feed
    when 2
      feeds = get_private_feed
    else
    end

    feed_container = {:feed=>feeds}
    respond_to do |format|
      format.json { render :json => feed_container.as_json, status: :ok }
    end
  end

  #use will_paginate gem
  def get_global_feed
    feed = FeedsHelper::get_feed_message_format(Feed.where('privacy = 0 AND status != 0').includes(:from_profile, :to_profile).order(id: :desc).first(100))
  end

  #hard-nailed solution
  def get_friends_feed
    ids = $user.get_friends_id
    FeedsHelper::get_feed_message_format(Feed.where('privacy = 0 AND status != 0 AND (to_profile_id in (:ids) OR from_profile_id in (:ids))', ids: ids).includes(:from_profile, :to_profile).order(id: :desc).first(100))
  end

  def get_private_feed
    FeedsHelper::get_feed_message_format(Feed.where('to_profile_id = :id OR from_profile_id = :id', id: $user.id).includes(:from_profile, :to_profile).order(status: :asc, id: :desc).first(100))
  end

end
