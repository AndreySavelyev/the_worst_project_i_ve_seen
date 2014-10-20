class ChangeColumnNameInWallets < ActiveRecord::Migration
  def change
     rename_column :wallets, :Profile_id, :profile_id
  end
end
