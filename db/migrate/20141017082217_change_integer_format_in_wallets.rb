class ChangeIntegerFormatInWallets < ActiveRecord::Migration
  def change
    change_column :wallets, :available, :float
    change_column :wallets, :holded, :float
  end
end
