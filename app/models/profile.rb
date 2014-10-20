class Profile < ActiveRecord::Base
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
    return profile;
  end
  
  def self.get_by_token(token)
    Profile.where("user_token = :accountid
                   OR email = :accountid OR fb_token = :accountid OR phone = :accountid",{accountid: token}).first
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

end
