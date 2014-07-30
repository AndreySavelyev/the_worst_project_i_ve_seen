class Profile < ActiveRecord::Base
  has_many :hot_offers, dependent: :destroy
  has_many :feeds, dependent: :destroy
end
