class CreateWallets < ActiveRecord::Migration
  def change
    create_table :wallets do |t|
      t.integer :available
      t.integer :holded
      t.belongs_to :Profile, index: true
      t.belongs_to :IsoCurrency, index: true

      t.timestamps
    end
  end
end
