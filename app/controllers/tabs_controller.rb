class TabsController < ApplicationController

  before_action :set_user_from_session, only: [:get_tabs]
  include GlobalConstants

  def get_tabs

    tabs = Tabs.new

    tabs.services = {:promolink => '#', :providers => format_services(Services::Service.get_all(GlobalConstants::CONTENT_STATE[:published]))}
    tabs.social = {:promolink => '#', :feeditem => ProfilesHelper::get_feed_message_format(Feed.where('privacy = 0 AND status = 1 AND "fType" != 3').includes(:from_profile, :to_profile).order(id: :desc).first(3))}
    tabs.shopping = {:promolink => '#', :hotoffer => format_offers(Shops::Offer.get_all(GlobalConstants::CONTENT_STATE[:published]).take(10))}

      respond_to do |format|
        format.json { render :json => tabs.as_json, status: :ok }
      end

  end

  def format_services(services)

    result = Array.new
    services.collect { |service|
      result << {
          :id => service.id,
          :pic => service.avatar.url(:thumb),
          :data => service.meta
      } }

    result
  end

  def format_offers(offers)

    result = Array.new

    offers.collect do |offer|
      result << {
          :id => offer.id,
          :title => offer.text,
          :currency => IsoCurrency.find(offer.currency).Alpha3Code,
          :price => offer.price,
          :username =>  offer.shop.name,
          :userpic => offer.shop.avatar_url,
          :pic => offer.avatar_medium_url
      }
    end
    result
  end

end
