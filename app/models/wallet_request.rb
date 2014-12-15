class WalletRequest < ActiveRecord::Base
  
  belongs_to :sourceWallet, :foreign_key => 'sourceWallet_id', :class_name => "Wallet"
  belongs_to :targetWallet, :foreign_key => 'targetWallet_id', :class_name => "Wallet"
    
  def self.create_cash_in_wallet_request(wallet_id)
    
    wr = WalletRequest.new
    wr.req_type = Entry::OPERATION_CODES[:cashin]
    wr.sourceWallet_id = wallet_id
    wr.targetWallet_id = wallet_id
    wr.token = SecureRandom.hex
    wr.save 
    
    return wr   
  end 
  
  
  def self.create_send_money_wallet_request(pay_request)
    
    wr = WalletRequest.new
    wr.req_type = Entry::OPERATION_CODES[:payment]
    wr.sourceWallet_id = pay_request.from_profile.get_wallet.id
    wr.targetWallet_id = pay_request.to_profile.get_wallet.id
    wr.feed_id = pay_request.id 
    wr.token = SecureRandom.hex
    wr.save
    
    return wr       
  end

  def self.create_return_money_wallet_request(pay_request)

    wr = WalletRequest.new
    wr.req_type = Entry::OPERATION_CODES[:cancellation]
    wr.sourceWallet_id = pay_request.from_profile.get_wallet.id
    wr.targetWallet_id = pay_request.to_profile.get_wallet.id
    wr.feed_id = pay_request.id
    wr.token = SecureRandom.hex
    wr.save

    return wr
  end

  def self.find_by_token(token)
    WalletRequest.where('token = :token',token: token).take!
  end


  def self.find_by_id(id)
    wr = WalletRequest.where('id = :id', id: id).first
    return wr
  end

  def self.delete_request(id)
    WalletRequest.delete(id)
  end

  def self.create_cashout_wallet_request(wallet_id)

    wr = WalletRequest.new
    wr.req_type = Entry::OPERATION_CODES[:cashout]
    wr.sourceWallet_id = wallet_id
    wr.targetWallet_id = wallet_id
    wr.token = SecureRandom.hex
    wr.save

    return wr
  end

  def self.create_password_recovery_request(wallet_id)



    wr = WalletRequest.new
    wr.req_type = Entry::OPERATION_CODES[:recovery]
    wr.sourceWallet_id = wallet_id
    wr.targetWallet_id = wallet_id
    wr.token = SecureRandom.hex
    wr.save

    return wr
  end

  def self.get_wallet_request_for_iban(iban, w)

    if iban.wr_token == nil
      wr = WalletRequest.create_cashout_wallet_request(w.id)
      iban.wr_token = wr.token
      iban.save!
    end

    wr = WalletRequest.find_by_token(iban.wr_token)

    return wr
  end
  
end
