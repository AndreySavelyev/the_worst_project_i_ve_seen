class Wallet < ActiveRecord::Base
  belongs_to :profile
  belongs_to :IsoCurrency
  belongs_to :session
  has_many :requests
  def self.create_wallet(profile)    
    wallet = Wallet.new
    wallet.profile = profile;
    wallet.IsoCurrency =  IsoCurrency.find_by! Alpha3Code: profile.iso_currency;
    wallet.available = 0;
    wallet.holded = 0;
    wallet.save!
    return wallet;
  end

  def self.get_wallet(profile)
    w = Wallet.where("profile_id = :id", id: profile.id).includes(:IsoCurrency).first
    if (w == nil)
      w = create_wallet(profile)
    end
    return w;
  end
  
  def self.get_wallet_by_id(id)
    Wallet.where("id = :id", id: id).includes(:IsoCurrency).first!
  end

end
