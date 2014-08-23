class Profile < ActiveRecord::Base
  has_many :hot_offers, dependent: :destroy
  has_many :sourceFeeds, :class_name => 'Feed', :foreign_key => 'to_profile_id'
  has_many :destinationFeeds, :class_name => 'Feed', :foreign_key => 'from_profile_id'
  has_one :wallet
  has_one :session
  has_many :BizAccountService, dependent: :destroy
end
