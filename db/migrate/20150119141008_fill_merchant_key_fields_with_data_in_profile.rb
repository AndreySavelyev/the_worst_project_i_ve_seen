class FillMerchantKeyFieldsWithDataInProfile < ActiveRecord::Migration
  def up
    Profile.find_each do |profile|
      profile.merchant_private_key = (profile.merchant_private_key == nil) ? SecureRandom.hex(10) : profile.merchant_private_key
      profile.merchant_token = (profile.merchant_token == nil) ? SecureRandom.hex(18) : profile.merchant_token
      profile.save!
    end
  end

  def down
  end
end
