class Entry < ActiveRecord::Base


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
  e.operation_code = 3
  e.save!
    
  return e      
end

end
