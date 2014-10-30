class Profile < ActiveRecord::Base
  
  ACCOUNT_TYPE = {personal: 0, green: 1, biz: 2, system: 100}
  
  has_many :hot_offers, dependent: :destroy
  has_many :sourceFeeds, :class_name => 'Feed', :foreign_key => 'to_profile_id'
  has_many :destinationFeeds, :class_name => 'Feed', :foreign_key => 'from_profile_id'
  has_one :wallet
  has_one :session
  has_many :BizAccountService, dependent: :destroy
  has_many :ibans, dependent: :destroy

  #связи друзей
  has_many :friends, :class_name => 'Friend'
  has_many :patients, through: :friends
  has_many :masters_profiles, :class_name => 'Friend'
  has_many :lovers, through: :masters_profiles

  has_attached_file :avatar, styles: {medium: ["300x300>", :png], thumb: ["51x51>", :png]}
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

  def avatar_url
    avatar.url(:thumb)
  end

  attr_accessor :image_data, :image

  def get_friends_id
    ids = lovers.pluck(:id);
  end

  def self.create(token)
    profile = Profile.new
    profile.user_token = token
    profile.wallet_type = ACCOUNT_TYPE[:personal]
    return profile
  end
  
  def self.get_by_token(token)
    Profile.where("user_token = :accountid
                   OR email = :accountid OR fb_token = :accountid OR phone = :accountid",{accountid: token}).first
  end
  
  def get_wallet
    if self.wallet == nil
      Wallet.create_wallet(self)
    end
    return wallet
  end

  def get_balance
    
    w = Wallet.get_wallet(self)
    
   {
      :wallet=>
      {
        :id=>w.id,
        :amount=>WalletHelper::format_to_currency(w.available),
        :currency=>w.IsoCurrency.Alpha3Code,
        :held=>w.holded,
        :limit=>2500,
        :revenue=>w.get_revenue
      }
    }
  end
  
  def get_stats
    {
      :stats=>
      {
        :friends=>lovers.count(),
        :new=>Feed::get_new(self)
      }
    }
  end
  
  def self.get_sys_profile(currency)
    Profile.where(:wallet_type =>  100, :iso_currency => currency).first!    
  end

  def decode_image_data
    puts "decoding"
    if self.image_data.present?
      # If image_data is present, it means that we were sent an image over
      # JSON and it needs to be decoded.  After decoding, the image is processed
      # normally via Paperclip.
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
