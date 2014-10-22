class Entry < ActiveRecord::Base

OPERATION_CODES = {cashin: 3, payment: 1, hold: 2}

def self.create_cashin_entry(amount, token)
  
    
  r = WalletRequest.find_by_token(token)
  
  e = Entry.new
  e.payment_request_id = r.id
  e.credit_profile_id = r.targetWallet.profile.id
  e.debt_profile_id = r.sourceWallet.profile.id
  e.credit_wallet_id = r.targetWallet.id
  e.debit_wallet_id = r.sourceWallet.id
  e.amount = amount
  e.currency_id = r.sourceWallet.IsoCurrency.id
  e.operation_code = OPERATION_CODES[:cashin]
  e.save!
    
  e.rollover
    
  return e
        
end

def self.create_hold_entry(wallet, r, amount)

  e = Entry.new
  e.payment_request_id = r.id
  e.credit_profile_id = r.targetWallet.profile.id
  e.debt_profile_id = r.sourceWallet.profile.id
  e.credit_wallet_id = r.targetWallet.id
  e.debit_wallet_id = r.sourceWallet.id
  e.amount = amount
  e.currency_id = r.sourceWallet.IsoCurrency.id
  e.operation_code = OPERATION_CODES[:hold]
  e.save!
  
  e.rollover
  
  return e
  
end

def rollover()
  
   credit_wallet = Wallet.get_wallet_by_id(self.credit_wallet_id);
   debit_wallet =  Wallet.get_wallet_by_id(self.debit_wallet_id);
   
   case self.operation_code
    when OPERATION_CODES[:cashin]
      credit_wallet.increment(:available, by = self.amount)  
      credit_wallet.save!    
    when OPERATION_CODES[:hold]
      debit_wallet.decrement(:available, by = self.amount)
      debit_wallet.increment(:holded, by = self.amount)
      debit_wallet.save!
    when 2
      feeds = get_private_feed();
    else
    end       
end

end
