class RemoveSourceCurrencyFromFeeds < ActiveRecord::Migration
  def change
    remove_column :feeds, :source_currency
  end
end
