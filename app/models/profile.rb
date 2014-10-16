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

  def self.get_by_token(token)

  end

  def get_balance
    balance = {
      :balance=>
      {
        :amount=>available,
        :currency=>iso_currency,
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
