class AddMerchantTokenToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :merchant_token, :string
    Profile.reset_column_information
    reversible do |dir|
      dir.up { Profile.update_all merchant_token: SecureRandom.hex(18) }
    end
  end
end

