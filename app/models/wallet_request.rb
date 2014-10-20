class WalletRequest < ActiveRecord::Base
  belongs_to :sourceWallet, :foreign_key => 'sourceWallet_id', :class_name => "Wallet"
  belongs_to :targetWallet, :foreign_key => 'targetWallet_id', :class_name => "Wallet"
    
  def self.create_cash_in_wallet_request(wallet_id)
    
    wr = WalletRequest.new
    wr.req_type = 3
    wr.sourceWallet_id = wallet_id
    wr.targetWallet_id = wallet_id
    wr.token = SecureRandom.hex
    wr.save 
    
    return wr   
  end
  
  def self.find_by_token(token)
    WalletRequest.where("token = :token",token: token).take!
  end
  
end
