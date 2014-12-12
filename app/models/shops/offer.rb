class Shops::Offer::NotOwner < StandardError

end

class Shops::Offer < ActiveRecord::Base
  belongs_to :shop

  def self.create_offer(shop_id, user_id, text, price, old_price, currency)

    shop = Shop.find(shop_id)
    if (shop != nil && shop.profile_id == user_id)
      offer = Offer.new
      offer.text = text
      offer.price = price
      offer.old_price = old_price
      offer.currency = IsoCurrency.find_by_Alpha3Code(currency).id
      offer.shop = shop
      offer.save!
      offer
    else
      raise Shops::Offer::NotOwner.new
    end
  end
end
