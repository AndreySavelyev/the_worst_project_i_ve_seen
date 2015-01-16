class ChangeFeedsComissionCurType < ActiveRecord::Migration
  def change
      remove_column :feeds, :commission_currency
      add_column :feeds, :commission_currency, :string
  end
end
