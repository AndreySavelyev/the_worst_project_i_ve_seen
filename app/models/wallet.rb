class Wallet < ActiveRecord::Base
  belongs_to :profile
  belongs_to :IsoCurrency
  belongs_to :session
  has_many :requests
    
  def self.create_wallet(profile)    
    wallet = Wallet.new
    wallet.profile = profile
    wallet.IsoCurrency =  IsoCurrency.find_by! Alpha3Code: profile.iso_currency
    wallet.available = 0
    wallet.holded = 0
    wallet.save!
    return wallet
  end

  def self.get_wallet(profile)
    w = Wallet.where("profile_id = :id", id: profile.id).includes(:IsoCurrency).first
    if w == nil
      w = create_wallet(profile)
    end
    return w
  end
  
  def self.get_wallet_by_id(id)
    Wallet.where('id = :id', id: id).includes(:IsoCurrency).first!
  end
  
  def hold(pay_request)         
     wr = WalletRequest.create_send_money_wallet_request(pay_request)
     Entry.create_hold_entry(wr, pay_request.amount)    
  end

  def get_revenue
    credit = Entry.sum(:credit_wallet_id)
    debit = Entry.sum(:debit_wallet_id)
    credit + debit
  end
  
end
