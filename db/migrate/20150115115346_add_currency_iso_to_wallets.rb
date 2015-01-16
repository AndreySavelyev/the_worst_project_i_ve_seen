class AddCurrencyIsoToWallets < ActiveRecord::Migration
  def up
      execute <<-SQL
        UPDATE wallets SET currency = iso_currencies."Alpha3Code" FROM iso_currencies WHERE wallets."IsoCurrency_id" = iso_currencies.id
      SQL
  end

  def down
    remove_column :wallets, :currency
  end
end
