class AddMerchantTokenToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :merchant_token, :string
  end
end

