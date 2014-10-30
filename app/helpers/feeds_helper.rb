module FeedsHelper
  
    def self.get_feed_message_format (feeds_list)
    feeds = Array.new
    if feeds_list
      feeds_list.each { |feed|
        format_feed(feed)
        feeds << format_feed(feed)
      }
    end
      return feeds
    end

    def self.format_feed(feed)
      {
          :id => feed.id,
          :message => feed.message,
          :from => "#{feed.from_profile.name} #{feed.from_profile.surname}",
          :from_id => feed.from_profile.user_token,
          :from_email => feed.from_profile.email,
          :to => "#{feed.to_profile.name} #{feed.to_profile.surname}",
          :to_id => feed.to_profile.user_token,
          :to_email => feed.to_profile.email,
          :global => feed.privacy,
          :date => feed.created_at.to_s(:session_date_time),
          :likes => feed.likes,
          :paymentId => feed.id,
          :for => feed.description,
          :pic => feed.from_profile.pic_url,
          :type => ProfilesHelper.get_feed_type_string(feed.fType, feed.status), #available types[charge, charge new, request, request new]
          :amount => feed.amount,
          :currency => feed.currency,
          :viewed => feed.viewed,
          :pic => feed.from_profile.avatar_url
      }
    end
  
end
