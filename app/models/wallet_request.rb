class WalletRequest < ActiveRecord::Base
  has_one :sourceWallet, :foreign_key => 'sourceWallet_id', :class_name => "Wallet"
  has_one :targetWallet, :foreign_key => 'targetWallet_id', :class_name => "Wallet"
end
