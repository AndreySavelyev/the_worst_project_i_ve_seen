class Profile < ActiveRecord::Base
  
  include GlobalConstants
  
  has_many :hot_offers, dependent: :destroy
  has_many :sourceFeeds, :class_name => 'Feed', :foreign_key => 'to_profile_id'
  has_many :destinationFeeds, :class_name => 'Feed', :foreign_key => 'from_profile_id'
  has_many :wallet
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
    lovers.pluck(:id);
  end

  def self.create(token)
    profile = Profile.new
    profile.user_token = token
    profile.wallet_type = GlobalConstants::ACCOUNT_TYPE[:personal]
    profile.merchant_token = SecureRandom.hex(18)
    profile.merchant_private_key = SecureRandom.hex(10)
    return profile
  end
  
  def self.get_by_token(token)
    Profile.where("user_token = :accountid
                   OR email = :accountid OR fb_token = :accountid OR phone = :accountid",{accountid: token}).first
  end

  def self.get_by_merchant_token(token)
    Profile.where("merchant_token = :token",{token: token}).first
  end

  def self.get_by_accountid(token)
    Profile.find_by_user_token(token)
  end

  def self.get_by_email(email)
    Profile.where("email = :email",{email: email}).first!
  end
  
  def get_wallet(currency)
      Wallet::get_wallet(self.id, currency)
  end

  def format_balance(wallet)
    {
        :wallet =>
            {
                :id => wallet.id,
                :amount => WalletHelper::format_to_currency(wallet.available),
                :currency => wallet.currency,
                :held => wallet.held,
                :limit => Limit::get(wallet.currency, wallet.profile.wallet_type).value,
                :revenue => wallet.get_revenue
            }
    }
  end

  def get_balance(currency)
    w = Wallet.get_wallet(self.id, currency)
    format_balance w
  end

  def get_balances()
    wallets = Array.new

    Wallet.get_wallets(self.id).collect do |w|
      wallets << format_balance(w)
    end

    wallets
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
  
  def self.get_sys_profile
    Profile.where(:wallet_type =>  100).first!
  end

  def decode_image_data
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

  def set_password(pass_phrase)
    self.salt = SecureRandom.hex
    self.password = Digest::SHA2.hexdigest(self.salt + pass_phrase)
    self.save!
  end

end
