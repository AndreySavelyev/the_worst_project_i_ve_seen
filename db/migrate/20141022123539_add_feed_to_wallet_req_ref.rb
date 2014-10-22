class AddFeedToWalletReqRef < ActiveRecord::Migration
  def change   
    add_reference :wallet_requests, :feed, index: true  
  end
end
