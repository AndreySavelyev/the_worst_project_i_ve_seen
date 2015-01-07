class NotShopOwner < StandardError

end

class Shops::Shop < ActiveRecord::Base

  belongs_to :profile

  has_attached_file :avatar, styles: {medium: ['300x300>', :png], thumb: ['51x51>', :png]}
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

  attr_accessor :image_data, :image

  def avatar_url
    avatar.url(:thumb)
  end

  def self.create_shop(user, name, text)

    shop = Shops::Shop.new
    shop.profile_id = user.id
    shop.text = text
    shop.name = name
    shop.save!
    shop

  end

  def self.get(id, user_id)

    shop = Shops::Shop.find(id)

    if (shop.profile_id == user_id)
      shop
    else
      raise Shop::NotOwner.new
    end

  end

  def decode_image_data
    if self.image_data.present? do
      # If image_data is present, it means that we were sent an image over
      # JSON and it needs to be decoded.  After decoding, the image is processed
      # normally via Paperclip.
      if self.image_data.present?
        data = StringIO.new(Base64.decode64(self.image_data))
        puts data
        data.class.class_eval { attr_accessor :original_filename, :content_type }
        data.original_filename = self.id.to_s + ".jpeg"
        data.content_type = "image/jpeg"
        self.avatar = data
        self.save!
      end
    end
    end
  end



end
