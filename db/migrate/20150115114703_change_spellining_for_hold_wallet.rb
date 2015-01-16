class ChangeSpelliningForHoldWallet < ActiveRecord::Migration
  def change
    rename_column :wallets, :holded, :held
  end
end
