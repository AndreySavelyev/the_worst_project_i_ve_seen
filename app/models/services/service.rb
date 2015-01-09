class NotServiceOwner < StandardError

end

class Services::Service < ActiveRecord::Base

  belongs_to :profile

  has_attached_file :avatar, styles: {medium: ['300x300>', :png], thumb: ['51x51>', :png]}
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

  attr_accessor :image_data, :image

  scope :all_tags, -> (tags){where('tags @> ARRAY[?] AND published = 1', tags)}

  def avatar_url
    avatar.url(:thumb)
  end

  def self.create_service(user, name, text, meta)

    service = Services::Service.new
    service.profile_id = user.id
    service.text = text
    service.name = name
    service.meta = meta
    service.save!
    service

  end

  def self.get(id, user_id)

    service = Services::Service.find(id)

    if service.profile_id == user_id
      service
    else
      raise Service::NotServiceOwner.new
    end

  end

  def self.update_service(id, user_id, content_type, text, name, meta)

    service = Services::Service.get(id, user_id)

    if (content_type < 3)
      service.published = content_type
    end

    service.text = text
    service.name = name
    service.meta = meta
    service.save!
    service
  end


  def decode_image_data
    if self.image_data.present?
      # If image_data is present, it means that we were sent an image over
      # JSON and it needs to be decoded.  After decoding, the image is processed
      # normally via 'Paperclip.
      if self.image_data.present?
        data = StringIO.new(Base64.decode64(self.image_data))
        data.class.class_eval {attr_accessor :original_filename, :content_type}
        data.original_filename = self.id.to_s + ".jpeg"
        data.content_type = "image/jpeg"
        self.avatar = data
        self.save!
      end
    end
  end

  def self.get_all(content_state)
    Services::Service.where(published: content_state).order(created_at: :desc)
  end

  def set_tags(tags, remove)

    tags_array = tags.split(',').collect(&:strip).uniq

    if self.tags == nil || remove
      self.update(tags: tags_array)
    else
      self.update(tags: self.tags | tags_array)
    end

    self.save!
    self
  end

end
