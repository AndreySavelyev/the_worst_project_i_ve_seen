class AddColumnToWalletRequests < ActiveRecord::Migration
  def change
    add_column :wallet_requests, :token, :string, :null => false
  end
end
