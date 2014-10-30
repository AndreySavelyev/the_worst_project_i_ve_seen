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

  def self.get_feed_type_string(feed_integer_type, status)
    #kovalevckiy via skype: pay, charge, pay new, charge new, request, ad

    if feed_integer_type === 0
      return 'request'
    end

    if feed_integer_type === 2 && status === 1
      return 'pay'
    end

    if feed_integer_type == 3 && status == 0
      return 'charge new'
    end

    if feed_integer_type == 3 && status == 1
      return 'charge'
    end

    if feed_integer_type === 2 && status === 0
      return 'pay new'
    end

    if feed_integer_type === 20
      return 'ad'
    end
  end

  def self.get_profile_format(user)
    {
        :profile =>
            {
                :accountid => user.user_token,
                :email => user.email,
                :type => user.wallet_type == 1 ? 'personal' : @user.wallet_type==2 ? 'green' : @user.wallet_type==3 ? 'biz' : @user.wallet_type == 4 ? 'biz partner' : @user.wallet_type == 5 ? 'pale' : 'personal', #available types[personal, green, biz, biz partner, pale]
                :firstName => user.name,
                :lastName => user.surname,
                :phone => user.phone,
                :fid => user.fb_token,
                :birthday => user.birthday,
                :address => user.address,
                :company_name => user.company_name,
                :web_site => user.web_site,
                :confirmed => (user.confirm_type!=nil && user.confirm_type!=0),
                :reg_number => user.company_reg_number,
                :cp_name => user.contact_person_name,
                :cp_position => user.contact_person_position,
                :cp_birth => user.contact_person_date_of_birth,
                :cp_phone => user.contact_person_phone,
                :balance => user.get_balance,
                :stats => user.get_stats,
                :pic => user.avatar_url,
                :mood => user.mood
            }
    }
  end

end
