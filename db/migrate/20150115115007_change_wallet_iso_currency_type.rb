class ChangeWalletIsoCurrencyType < ActiveRecord::Migration
  def change
    add_column :wallets, :currency, :string
  end
end
