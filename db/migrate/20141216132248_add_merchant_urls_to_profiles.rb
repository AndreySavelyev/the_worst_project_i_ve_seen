class AddMerchantUrlsToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :merchant_success_url, :string
    add_column :profiles, :merchant_fail_url, :string
  end
end
