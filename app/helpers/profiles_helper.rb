module ProfilesHelper
  :public
  def self.get_tabs_format (user, app)

    @apps = Array.new
    app.providers.collect do |provider|
      @apps << {
          :id => provider.id,
          :pic=> provider.pic,
          :apidata=> provider.apiData
      } end

    @socialCol = Array.new
    user.feeds.collect do |feed|
      @socialCol << {
          :id => feed.id,
          :date => feed.feedDate,
          :likes=> 10,
          :message=> feed.message,
          :userpic=> feed.profile.pic_url,
          :type=> feed.feedType
      } end

    @hotOffers = Array.new
    user.hot_offers.collect do |hotOffer|
      @hotOffers << {
          :id => hotOffer.id,
          :title => hotOffer.title,
          :currency=> hotOffer.currency,
          :price=>hotOffer.price,
          :username=> hotOffer.profile.name,
          :userpic=> hotOffer.profile.pic_url,
          :pic=> hotOffer.pic_url
      } end

    @services = Services.new;
    @services.promolink="http://chargebutton.com/";
    @services.provider = @apps;

    @social = Services.new;
    @social.promolink="http://chargebutton.com/api.html";
    @social.feeditem = @socialCol;

    @shopping = Services.new;
    @shopping.promolink="http://chargebutton.com/new.html";
    @shopping.hotoffer = @hotOffers;

    @tabs = Tabs.new;
    @tabs.services=@services;
    @tabs.social =@social;
    @tabs.shopping= @shopping;

    return @tabs;
  end

end
