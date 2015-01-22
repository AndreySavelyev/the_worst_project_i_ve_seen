module ProfilesHelper

  include GlobalConstants

  def self.get_tabs_format (user, app)

    #@apps = user.BizAccountService;
    apps = Array.new

    BizAccountService.all.collect do |srvc|
      apps << {
          :id => user.user_token,
          :pic => srvc.pic,
          :data=> srvc.api_data
      } end

    feeds = get_feed_message_format(Feed.where('privacy = 0 AND status = 1 AND "fType" != 3').includes(:from_profile, :to_profile).order(id: :desc).first(5))

    hotOffers = Array.new
    HotOffer.all.order('created_at DESC').collect   do |hotOffer|
      hotOffers << {
          :id => hotOffer.id,
          :title => hotOffer.title,
          :currency => hotOffer.currency,
          :price => hotOffer.price,
          :username => hotOffer.profile.name,
          :userpic => hotOffer.profile.pic_url,
          :pic => hotOffer.pic_url
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
    tabs.services = services;
    tabs.social = social;
    tabs.shopping = shopping;

    return tabs;
  end

  def self.get_feed_message_format (feeds_list)
    feeds = Array.new
    if feeds_list
      feeds_list.each { |feed|
        feeds << FeedsHelper::format_feed(feed)
        }
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

    if feed_integer_type == GlobalConstants::REQUEST_TYPES[:friendship] && status == 1
      return 'request'
    end

    if feed_integer_type == GlobalConstants::REQUEST_TYPES[:friendship] && status == 0
      return 'request new'
    end

    if feed_integer_type == GlobalConstants::REQUEST_TYPES[:friendship] && status == 2
      return 'request declined'
    end

    if feed_integer_type == GlobalConstants::REQUEST_TYPES[:pay] && status == 1
      return 'pay'
    end

    if feed_integer_type == GlobalConstants::REQUEST_TYPES[:charge] && status == 0
      return 'charge new'
    end

    if feed_integer_type == GlobalConstants::REQUEST_TYPES[:charge] && status == 1
      return 'charge'
    end

    if feed_integer_type == GlobalConstants::REQUEST_TYPES[:pay] && status == 0
      return 'pay new'
    end

    if feed_integer_type == GlobalConstants::REQUEST_TYPES[:pay] && status == 2
      return 'pay declined'
    end

    if feed_integer_type == GlobalConstants::REQUEST_TYPES[:ad]
      return 'ad'
    end
  end

  def self.get_string_type(int_type)
    case int_type
      when Profile::ACCOUNT_TYPE[:personal]
        'personal'
      when Profile::ACCOUNT_TYPE[:green]
        'green'
      when Profile::ACCOUNT_TYPE[:biz]
        'biz'
      when Profile::ACCOUNT_TYPE[:partner]
        'biz partner'
      when Profile::ACCOUNT_TYPE[:pale]
        'pale'
    end
  end

  def self.format_profile(user, currency)
    {
        :profile =>
            {
                :accountid => user.user_token,
                :email => user.email,
                :type => get_string_type(user.wallet_type),
                :type_code => user.wallet_type,
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
                :balance => user.get_balance(currency),
                :balances => user.get_balances(),
                :stats => user.get_stats,
                :pic => user.avatar_url,
                :mood => user.mood
            }
    }
  end

  def self.trust_user(password1, password2, trusted_accountid)

    !trusted_accountid ? (password1 == password2) : trusted_accountid

  end

end
