class FixMerchantCallbacks < ActiveRecord::Migration
  def change
    change_table :profiles do |t|
      t.rename :merchant_success_url, :merchant_callback
      t.remove :merchant_fail_url
    end
  end
end
