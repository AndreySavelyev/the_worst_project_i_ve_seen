module ProfilesHelper

  def self.get_tabs_format (user, app)

    #@apps = user.BizAccountService;
    apps = Array.new
    BizAccountService.all.collect do |srvc|
      apps << {
          :id => user.user_token,
          :pic => srvc.pic,
          :data=> srvc.api_data
      } end

    feeds = get_feed_message_format(Feed.where("(privacy = 0 OR privacy = 1) AND status != 0").includes(:from_profile, :to_profile).first(2))

    hotOffers = Array.new
    HotOffer.all.order('created_at DESC').collect   do |hotOffer|
      hotOffers << {
          :id => hotOffer.id,
          :title => hotOffer.title,
          :currency=> hotOffer.currency,
          :price=>hotOffer.price,
          :username=> hotOffer.profile.name,
          :userpic=> hotOffer.profile.pic_url,
          :pic=> hotOffer.pic_url
      } end

    services = Services.new;
    services.promolink="http://chargebutton.com/";
    services.provider = apps;

    social = Services.new;
    social.promolink="http://chargebutton.com/api.html";
    social.feeditem = feeds;

    shopping = Services.new;
    shopping.promolink="http://chargebutton.com/new.html";
    shopping.hotoffer = hotOffers;

    tabs = Tabs.new;
    tabs.services=services;
    tabs.social =social;
    tabs.shopping= shopping;

    return tabs;
  end

  def self.get_feed_message_format (feeds_list)
    feeds = Array.new
    if feeds_list
      feeds_list.each { |feed|
        feeds << {
            :id => feed.id,
            :message => feed.message,
            :from => "#{feed.from_profile.name} #{feed.from_profile.surname}",
            :from_id => feed.from_profile.user_token,
            :to => "#{feed.to_profile.name} #{feed.to_profile.surname}",
            :to_id => feed.to_profile.user_token,
            :global => feed.privacy,
            :date => feed.created_at.to_s(:session_date_time),
            :likes => feed.likes,
            :paymentId => feed.id,
            :for => feed.description,
            :pic => feed.from_profile.pic_url,
            :type => ProfilesHelper.get_feed_type_string(feed.fType), #available types[charge, charge new, request, request new]
            :amount => feed.amount,
            :currency => feed.currency,
            :viewed => feed.viewed
        } }
    end
    return feeds;
  end

  def self.get_privacy_string(privacy_integer_type)
    if(privacy_integer_type === 0)
      return 'global'
    end
    if(privacy_integer_type === 1)
      return 'friends'
    end
    if(privacy_integer_type === 2)
      return 'private'
    end
    return 'unknown privacy type'
  end

  def self.get_feed_type_string(feed_integer_type)
    #kovalevckiy via skype: pay, charge, pay new, charge new, request, ad

    if feed_integer_type === 0
      return 'request'
    end

    if feed_integer_type === 1
      return 'charge'
    end

    if feed_integer_type === 2
      return 'pay'
    end

    if feed_integer_type === 3
      return 'charge new'
    end

    if feed_integer_type === 4
      return 'pay new'
    end

    if feed_integer_type === 20
      return 'ad'
    end
  end
end
