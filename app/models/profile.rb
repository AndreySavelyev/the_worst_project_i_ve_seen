class Profile < ActiveRecord::Base
  
  ACCOUNT_TYPE = {personal: 0, green: 1, biz: 2, system: 100}
  
  has_many :hot_offers, dependent: :destroy
  has_many :sourceFeeds, :class_name => 'Feed', :foreign_key => 'to_profile_id'
  has_many :destinationFeeds, :class_name => 'Feed', :foreign_key => 'from_profile_id'
  has_one :wallet
  has_one :session
  has_many :BizAccountService, dependent: :destroy

  #связи друзей
  has_many :friends, :class_name => 'Friend'
  has_many :patients, through: :friends
  has_many :masters_profiles, :class_name => 'Friend'
  has_many :lovers, through: :masters_profiles
  def get_friends_id
    ids = lovers.pluck(:id);
  end

  def self.create(token)
    profile = Profile.new
    profile.user_token = token
    profile.wallet_type = ACCOUNT_TYPE[:personal]
    return profile;
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
    
    balance = {
      :wallet=>
      {
        :id=>w.id,
        :amount=>w.available,
        :currency=>w.IsoCurrency.Alpha3Code,
        :holded=>w.holded,
        :limit=>2500
      }
    }
  end
  
  def get_stats
    stats = {
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

end
