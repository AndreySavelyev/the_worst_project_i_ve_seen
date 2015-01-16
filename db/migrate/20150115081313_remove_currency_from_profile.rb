class RemoveCurrencyFromProfile < ActiveRecord::Migration
  def change
    remove_column :profiles, :iso_currency
  end
end
