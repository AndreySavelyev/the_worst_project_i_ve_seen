class Wallet < ActiveRecord::Base

  belongs_to :profile
  belongs_to :IsoCurrency
  belongs_to :session
  has_many :requests
    
  def self.create_wallet(profile_id, currency)
    wallet = Wallet.new
    wallet.profile_id = profile_id
    wallet.currency = currency
    wallet.available = 0
    wallet.held = 0
    wallet.save!
    return wallet
  end

  def self.get_wallet(profile_id, currency)
    w = Wallet.where("profile_id = :id AND currency = :currency", id: profile_id, currency: currency.upcase).first
    if w == nil
      w = create_wallet(profile_id, currency.upcase)
    end
    return w
  end

  def self.get_wallets(profile_id)
    Wallet.where("profile_id = :id", id: profile_id)
  end
  
  def self.get_wallet_by_id(id)
    Wallet.where('id = :id', id: id).first!
  end
  
  def hold(pay_request)
     wr = WalletRequest.create_send_money_wallet_request(pay_request)
     Entry.create_hold_entry(wr, pay_request.amount)    
  end

  def cancel_hold(pay_request)
    wr = WalletRequest.create_return_money_wallet_request(pay_request)
    Entry.create_cancellation_entry(wr, pay_request.amount)
  end

  def get_revenue
    Entry.where("credit_wallet_id = :wallet_id OR debit_wallet_id = :wallet_id", wallet_id: self.id).sum(:amount)
  end
  
end
