class AddMerchantPrivateKeyToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :merchant_private_key, :string
  end
end
