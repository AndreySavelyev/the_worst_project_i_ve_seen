class NotOfferOwner < StandardError

end

class Shops::Offer < ActiveRecord::Base

  belongs_to :shop

  has_attached_file :avatar, styles: {medium: ['300x300>', :png], thumb: ['51x51>', :png]}
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

  attr_accessor :image_data, :image

  def self.create_offer(shop_id, user_id, text, price, old_price, currency, url)

    shop = Shops::Shop.find(shop_id)
    if (shop != nil && shop.profile_id == user_id)
      offer = Shops::Offer.new
      offer.text = text
      offer.price = price
      offer.old_price = old_price
      offer.currency = IsoCurrency.find_by_Alpha3Code(currency).id
      offer.shop = shop
      offer.url = url
      offer.save!
      offer
    else
      raise Offer::NotOfferOwner.new
    end
  end

  def self.get(id, user_id)

    offer = Shops::Offer.find(id)

    if (offer.shop.profile_id == user_id)
      offer
    else
      raise Offer::NotOfferOwner.new
    end

  end

  def decode_image_data
    if self.image_data.present?
      # If image_data is present, it means that we were sent an image over
      # JSON and it needs to be decoded.  After decoding, the image is processed
      # normally via 'Paperclip.
      if self.image_data.present?
        data = StringIO.new(Base64.decode64(self.image_data))
        puts data
        data.class.class_eval {attr_accessor :original_filename, :content_type}
        data.original_filename = self.id.to_s + ".jpeg"
        data.content_type = "image/jpeg"
        self.avatar = data
        self.save!
      end
    end
  end


end
