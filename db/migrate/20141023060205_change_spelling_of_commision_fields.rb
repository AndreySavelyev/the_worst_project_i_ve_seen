class ChangeSpellingOfCommisionFields < ActiveRecord::Migration
  def change
    rename_column :feeds, :comission_value, :commission_value
    rename_column :feeds, :trans_commission_amount, :commission_amount
    rename_column :feeds, :trans_commission_currency, :commission_currency
  end
end
