class CreateWalletRequests < ActiveRecord::Migration
  def change
    create_table :wallet_requests do |t|
      t.integer :req_type
      t.integer :req_status
      t.integer :sourceWallet_id
      t.integer :targetWallet_id

      t.timestamps
    end
  end
end
