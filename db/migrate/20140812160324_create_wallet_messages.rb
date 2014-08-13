class CreateWalletMessages < ActiveRecord::Migration
  def change
    create_table :wallet_messages do |t|
      t.string :message
      t.references :Request, index: true

      t.timestamps
    end
  end
end
